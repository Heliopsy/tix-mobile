#ifndef RUNNER_DESKTOP_H_
#define RUNNER_DESKTOP_H_

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

// The runner's side of tix/links (tix:// links handed to Dart) and
// tix/desktop (what the desktop offers, start at login, the quick-add
// hotkey, the tray icon's hover text). See
// lib/src/core/platform/deep_links.dart and desktop.dart.
typedef struct _TixDesktop TixDesktop;

// Listens on the two channels of `messenger`. `background` says this launch
// came from the login item, so the window starts hidden.
TixDesktop* tix_desktop_new(FlBinaryMessenger* messenger, gboolean background);

// Holds `uri` for Dart to take, and tells Dart if it is listening.
void tix_desktop_open_link(TixDesktop* self, const gchar* uri);

// Drops the hotkey and the channels.
void tix_desktop_free(TixDesktop* self);

#endif  // RUNNER_DESKTOP_H_
