#include "desktop.h"

#include <dlfcn.h>
#include <gio/gio.h>
#include <glib/gstdio.h>
#include <string.h>

#ifdef GDK_WINDOWING_X11
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <gdk/gdkx.h>
#endif

struct _TixDesktop {
  FlMethodChannel* links;
  FlMethodChannel* desktop;
  gchar* pending_link;
  gboolean listening;
  gboolean background;
  gboolean grabbed;
  guint keycode;
  gpointer indicator_class;
  guint status_signal;
  gulong status_hook;
  GObject* indicator;
};

static FlMethodResponse* success(FlValue* value) {
  return FL_METHOD_RESPONSE(fl_method_success_response_new(value));
}

static void respond(FlMethodCall* call, FlMethodResponse* response) {
  g_autoptr(GError) error = nullptr;
  if (!fl_method_call_respond(call, response, &error)) {
    g_warning("tix/desktop: could not respond: %s", error->message);
  }
  g_object_unref(response);
}

static gboolean in_flatpak() {
  return g_file_test("/.flatpak-info", G_FILE_TEST_EXISTS);
}

// Whether a StatusNotifierWatcher runs on the session bus. KDE, Xfce,
// Cinnamon, Budgie and GNOME with the AppIndicator extension have one; plain
// GNOME does not, and an icon added there would never show.
static gboolean tray_available() {
  g_autoptr(GError) error = nullptr;
  g_autoptr(GDBusConnection) bus =
      g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, &error);
  if (bus == nullptr) {
    return FALSE;
  }
  g_autoptr(GVariant) reply = g_dbus_connection_call_sync(
      bus, "org.freedesktop.DBus", "/org/freedesktop/DBus",
      "org.freedesktop.DBus", "NameHasOwner",
      g_variant_new("(s)", "org.kde.StatusNotifierWatcher"),
      G_VARIANT_TYPE("(b)"), G_DBUS_CALL_FLAGS_NONE, 1000, nullptr, &error);
  if (reply == nullptr) {
    return FALSE;
  }
  gboolean owned = FALSE;
  g_variant_get(reply, "(b)", &owned);
  return owned;
}

static gboolean hotkeys_available() {
#ifdef GDK_WINDOWING_X11
  return GDK_IS_X11_DISPLAY(gdk_display_get_default());
#else
  return FALSE;
#endif
}

// ---------------------------------------------------------------- links

static void links_call(FlMethodChannel* channel, FlMethodCall* call,
                       gpointer user_data) {
  TixDesktop* self = static_cast<TixDesktop*>(user_data);
  if (strcmp(fl_method_call_get_name(call), "take") != 0) {
    respond(call, FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()));
    return;
  }
  self->listening = TRUE;
  FlValue* link = self->pending_link == nullptr
                      ? fl_value_new_null()
                      : fl_value_new_string(self->pending_link);
  g_clear_pointer(&self->pending_link, g_free);
  respond(call, success(link));
}

void tix_desktop_open_link(TixDesktop* self, const gchar* uri) {
  g_free(self->pending_link);
  self->pending_link = g_strdup(uri);
  if (self->listening) {
    fl_method_channel_invoke_method(self->links, "opened", nullptr, nullptr,
                                    nullptr, nullptr);
  }
}

// ---------------------------------------------------------------- autostart

static gchar* autostart_path() {
  return g_build_filename(g_get_user_config_dir(), "autostart",
                          APPLICATION_ID ".desktop", nullptr);
}

// Writes or removes ~/.config/autostart/<id>.desktop, starting this
// executable hidden.
static gboolean set_autostart_file(gboolean on) {
  g_autofree gchar* path = autostart_path();
  if (!on) {
    return g_remove(path) == 0 || !g_file_test(path, G_FILE_TEST_EXISTS);
  }
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
  if (exe == nullptr) {
    return FALSE;
  }
  g_autofree gchar* dir = g_path_get_dirname(path);
  if (g_mkdir_with_parents(dir, 0700) != 0) {
    return FALSE;
  }
  g_autoptr(GString) exec = g_string_new("\"");
  for (const gchar* c = exe; *c != '\0'; c++) {
    if (strchr("\"`$\\", *c) != nullptr) {
      g_string_append_c(exec, '\\');
    }
    g_string_append_c(exec, *c);
  }
  g_string_append(exec, "\" --background");
  g_autoptr(GKeyFile) file = g_key_file_new();
  const gchar* group = G_KEY_FILE_DESKTOP_GROUP;
  g_key_file_set_string(file, group, G_KEY_FILE_DESKTOP_KEY_TYPE, "Application");
  g_key_file_set_string(file, group, G_KEY_FILE_DESKTOP_KEY_NAME, "tix");
  g_key_file_set_string(file, group, G_KEY_FILE_DESKTOP_KEY_EXEC, exec->str);
  g_key_file_set_string(file, group, G_KEY_FILE_DESKTOP_KEY_ICON,
                        APPLICATION_ID);
  g_key_file_set_boolean(file, group, G_KEY_FILE_DESKTOP_KEY_TERMINAL, FALSE);
  g_key_file_set_boolean(file, group, "X-GNOME-Autostart-enabled", TRUE);
  return g_key_file_save_to_file(file, path, nullptr);
}

typedef struct {
  FlMethodCall* call;
  GDBusConnection* bus;
  guint subscription;
} BackgroundRequest;

static void background_done(BackgroundRequest* request, gboolean ok) {
  g_dbus_connection_signal_unsubscribe(request->bus, request->subscription);
  respond(request->call, success(fl_value_new_bool(ok)));
  g_object_unref(request->call);
  g_object_unref(request->bus);
  g_free(request);
}

static void background_answered(GDBusConnection* bus, const gchar* sender,
                                const gchar* path, const gchar* interface,
                                const gchar* signal, GVariant* parameters,
                                gpointer user_data) {
  BackgroundRequest* request = static_cast<BackgroundRequest*>(user_data);
  guint32 code = 2;
  g_autoptr(GVariant) results = nullptr;
  g_variant_get(parameters, "(u@a{sv})", &code, &results);
  background_done(request, code == 0);
}

// No portal, or it refused the call: no Response will come.
static void background_requested(GObject* source, GAsyncResult* result,
                                 gpointer user_data) {
  g_autoptr(GError) error = nullptr;
  g_autoptr(GVariant) reply = g_dbus_connection_call_finish(
      G_DBUS_CONNECTION(source), result, &error);
  if (reply == nullptr) {
    g_warning("tix/desktop: Background portal: %s", error->message);
    background_done(static_cast<BackgroundRequest*>(user_data), FALSE);
  }
}

// Inside Flatpak the sandbox cannot write the host's autostart folder; the
// Background portal does it, and may ask the person first. The answer comes
// as a Response signal on a request path built from a token of our own, so
// the subscription is in place before the call can be answered.
static void set_autostart_portal(FlMethodCall* call, gboolean on) {
  g_autoptr(GError) error = nullptr;
  GDBusConnection* bus = g_bus_get_sync(G_BUS_TYPE_SESSION, nullptr, &error);
  if (bus == nullptr) {
    respond(call, success(fl_value_new_bool(FALSE)));
    return;
  }
  g_autofree gchar* token =
      g_strdup_printf("tix%d", g_random_int_range(1, G_MAXINT32));
  g_autofree gchar* sender =
      g_strdup(g_dbus_connection_get_unique_name(bus) + 1);
  for (gchar* c = sender; *c != '\0'; c++) {
    if (*c == '.') {
      *c = '_';
    }
  }
  g_autofree gchar* handle = g_strdup_printf(
      "/org/freedesktop/portal/desktop/request/%s/%s", sender, token);

  BackgroundRequest* request = g_new0(BackgroundRequest, 1);
  request->call = FL_METHOD_CALL(g_object_ref(call));
  request->bus = bus;
  request->subscription = g_dbus_connection_signal_subscribe(
      bus, "org.freedesktop.portal.Desktop", "org.freedesktop.portal.Request",
      "Response", handle, nullptr, G_DBUS_SIGNAL_FLAGS_NO_MATCH_RULE,
      background_answered, request, nullptr);

  GVariantBuilder options;
  g_variant_builder_init(&options, G_VARIANT_TYPE_VARDICT);
  g_variant_builder_add(&options, "{sv}", "handle_token",
                        g_variant_new_string(token));
  g_variant_builder_add(&options, "{sv}", "reason",
                        g_variant_new_string("Start tix at login"));
  g_variant_builder_add(&options, "{sv}", "autostart",
                        g_variant_new_boolean(on));
  const gchar* command[] = {"tix_mobile", "--background", nullptr};
  g_variant_builder_add(&options, "{sv}", "commandline",
                        g_variant_new_strv(command, -1));
  g_dbus_connection_call(
      bus, "org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop",
      "org.freedesktop.portal.Background", "RequestBackground",
      g_variant_new("(sa{sv})", "", &options), G_VARIANT_TYPE("(o)"),
      G_DBUS_CALL_FLAGS_NONE, -1, nullptr, background_requested, request);
}

// ---------------------------------------------------------------- hotkey

#ifdef GDK_WINDOWING_X11
static const guint kHotkeyModifiers = ControlMask | ShiftMask;
// NumLock and CapsLock change the state X reports, so each combination is
// grabbed.
static const guint kLockMasks[] = {0, LockMask, Mod2Mask, LockMask | Mod2Mask};

static GdkFilterReturn hotkey_filter(GdkXEvent* xevent, GdkEvent* event,
                                     gpointer user_data) {
  TixDesktop* self = static_cast<TixDesktop*>(user_data);
  XEvent* e = static_cast<XEvent*>(xevent);
  if (e->type != KeyPress || e->xkey.keycode != self->keycode) {
    return GDK_FILTER_CONTINUE;
  }
  if ((e->xkey.state & ~(LockMask | Mod2Mask)) != kHotkeyModifiers) {
    return GDK_FILTER_CONTINUE;
  }
  fl_method_channel_invoke_method(self->desktop, "hotkey", nullptr, nullptr,
                                  nullptr, nullptr);
  return GDK_FILTER_REMOVE;
}

static void ungrab(TixDesktop* self, Display* x, Window root) {
  for (guint mask : kLockMasks) {
    XUngrabKey(x, self->keycode, kHotkeyModifiers | mask, root);
  }
}
#endif

// Ctrl+Shift+Space on the X11 root window. Wayland offers no global
// hotkeys, and the setting is not shown there.
static gboolean set_hotkey(TixDesktop* self, gboolean on) {
#ifdef GDK_WINDOWING_X11
  GdkDisplay* display = gdk_display_get_default();
  if (!GDK_IS_X11_DISPLAY(display)) {
    return FALSE;
  }
  Display* x = GDK_DISPLAY_XDISPLAY(display);
  Window root = DefaultRootWindow(x);
  GdkWindow* gdk_root = gdk_get_default_root_window();
  if (!on) {
    if (self->grabbed) {
      ungrab(self, x, root);
      gdk_window_remove_filter(gdk_root, hotkey_filter, self);
      self->grabbed = FALSE;
    }
    return TRUE;
  }
  if (self->grabbed) {
    return TRUE;
  }
  self->keycode = XKeysymToKeycode(x, XK_space);
  gdk_x11_display_error_trap_push(display);
  for (guint mask : kLockMasks) {
    XGrabKey(x, self->keycode, kHotkeyModifiers | mask, root, False,
             GrabModeAsync, GrabModeAsync);
  }
  XSync(x, False);
  if (gdk_x11_display_error_trap_pop(display) != 0) {
    gdk_x11_display_error_trap_push(display);
    ungrab(self, x, root);
    gdk_x11_display_error_trap_pop_ignored(display);
    return FALSE;
  }
  gdk_window_add_filter(gdk_root, hotkey_filter, self);
  self->grabbed = TRUE;
  return TRUE;
#else
  return FALSE;
#endif
}

// ---------------------------------------------------------------- tray

// tray_manager keeps its AppIndicator in a hidden global and has no tooltip
// on Linux. Its setIcon turns the indicator active, which emits
// "new-status"; an emission hook on that signal hands over the instance.
// The library is already loaded for the plugin, so dlsym finds its type
// without linking it here, and nothing happens where it is missing.
static gboolean indicator_seen(GSignalInvocationHint* hint, guint n_params,
                               const GValue* params, gpointer user_data) {
  TixDesktop* self = static_cast<TixDesktop*>(user_data);
  GObject* indicator = G_OBJECT(g_value_get_object(&params[0]));
  if (indicator != self->indicator) {
    if (self->indicator != nullptr) {
      g_object_remove_weak_pointer(
          self->indicator, reinterpret_cast<gpointer*>(&self->indicator));
    }
    self->indicator = indicator;
    g_object_add_weak_pointer(indicator,
                              reinterpret_cast<gpointer*>(&self->indicator));
  }
  return TRUE;
}

static void watch_indicator(TixDesktop* self) {
  using GetType = GType (*)();
  GetType get_type = reinterpret_cast<GetType>(
      dlsym(RTLD_DEFAULT, "app_indicator_get_type"));
  if (get_type == nullptr) {
    return;
  }
  GType type = get_type();
  self->indicator_class = g_type_class_ref(type);
  self->status_signal = g_signal_lookup("new-status", type);
  if (self->status_signal != 0) {
    self->status_hook = g_signal_add_emission_hook(
        self->status_signal, 0, indicator_seen, self, nullptr);
  }
}

static const gchar* string_arg(FlValue* args, const gchar* key) {
  FlValue* value = fl_value_lookup_string(args, key);
  return value != nullptr && fl_value_get_type(value) == FL_VALUE_TYPE_STRING
             ? fl_value_get_string(value)
             : "";
}

static gboolean has_property(GObject* object, const gchar* name) {
  return g_object_class_find_property(G_OBJECT_GET_CLASS(object), name) !=
         nullptr;
}

// KDE shows the SNI ToolTip on hover and names the item by its Title.
// libayatana-appindicator exports a ToolTip only from 0.6 on, so the
// headline also goes into the title, which every version has.
static gboolean set_tray_status(TixDesktop* self, FlValue* args) {
  if (self->indicator == nullptr || args == nullptr ||
      fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    return FALSE;
  }
  const gchar* title = string_arg(args, "title");
  if (has_property(self->indicator, "title")) {
    g_object_set(self->indicator, "title", title, nullptr);
  }
  if (has_property(self->indicator, "tooltip-title") &&
      has_property(self->indicator, "tooltip-body")) {
    g_object_set(self->indicator, "tooltip-title", title, "tooltip-body",
                 string_arg(args, "body"), nullptr);
  }
  return TRUE;
}

// ---------------------------------------------------------------- desktop

static gboolean bool_arg(FlMethodCall* call) {
  FlValue* args = fl_method_call_get_args(call);
  return args != nullptr && fl_value_get_type(args) == FL_VALUE_TYPE_BOOL &&
         fl_value_get_bool(args);
}

static void desktop_call(FlMethodChannel* channel, FlMethodCall* call,
                         gpointer user_data) {
  TixDesktop* self = static_cast<TixDesktop*>(user_data);
  const gchar* method = fl_method_call_get_name(call);
  if (strcmp(method, "capabilities") == 0) {
    FlValue* caps = fl_value_new_map();
    fl_value_set_string_take(caps, "tray", fl_value_new_bool(tray_available()));
    fl_value_set_string_take(caps, "autostart", fl_value_new_bool(TRUE));
    fl_value_set_string_take(caps, "hotkey",
                             fl_value_new_bool(hotkeys_available()));
    fl_value_set_string_take(caps, "background",
                             fl_value_new_bool(self->background));
    respond(call, success(caps));
  } else if (strcmp(method, "autostart") == 0) {
    if (in_flatpak()) {
      respond(call, success(fl_value_new_null()));
      return;
    }
    g_autofree gchar* path = autostart_path();
    respond(call, success(fl_value_new_bool(
                      g_file_test(path, G_FILE_TEST_EXISTS))));
  } else if (strcmp(method, "setAutostart") == 0) {
    if (in_flatpak()) {
      set_autostart_portal(call, bool_arg(call));
      return;
    }
    respond(call, success(fl_value_new_bool(set_autostart_file(bool_arg(call)))));
  } else if (strcmp(method, "setHotkey") == 0) {
    respond(call, success(fl_value_new_bool(set_hotkey(self, bool_arg(call)))));
  } else if (strcmp(method, "setTrayStatus") == 0) {
    respond(call, success(fl_value_new_bool(
                      set_tray_status(self, fl_method_call_get_args(call)))));
  } else {
    respond(call, FL_METHOD_RESPONSE(fl_method_not_implemented_response_new()));
  }
}

TixDesktop* tix_desktop_new(FlBinaryMessenger* messenger, gboolean background) {
  TixDesktop* self = g_new0(TixDesktop, 1);
  self->background = background;
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->links =
      fl_method_channel_new(messenger, "tix/links", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->links, links_call, self,
                                            nullptr);
  self->desktop =
      fl_method_channel_new(messenger, "tix/desktop", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(self->desktop, desktop_call, self,
                                            nullptr);
  watch_indicator(self);
  return self;
}

void tix_desktop_free(TixDesktop* self) {
  set_hotkey(self, FALSE);
  if (self->status_hook != 0) {
    g_signal_remove_emission_hook(self->status_signal, self->status_hook);
  }
  if (self->indicator != nullptr) {
    g_object_remove_weak_pointer(self->indicator,
                                 reinterpret_cast<gpointer*>(&self->indicator));
  }
  if (self->indicator_class != nullptr) {
    g_type_class_unref(self->indicator_class);
  }
  g_clear_object(&self->links);
  g_clear_object(&self->desktop);
  g_free(self->pending_link);
  g_free(self);
}
