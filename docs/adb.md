# Controlling tix over ADB

With the phone on USB (or wireless debugging) and `adb` on your computer, you can read the app's state, open any
screen with a `tix://` link and drive it with shell commands. Android only. Everything below is copy-paste ready;
the package is `red.tix.tix_mobile` in every build.

| Layer | Command | Needs |
| --- | --- | --- |
| [Read state](#reading-state-with-dumpsys) | `adb shell dumpsys activity service ...` | Nothing |
| [Open screens](#links) | `adb shell am start -a android.intent.action.VIEW -d tix://...` | Nothing |
| [Run commands](#commands) | `adb shell am broadcast ... --es cmd <name>` | Debug build, or the setting on |

## Reading state with dumpsys

```sh
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService
```

That prints every section. Add a section name to print one:

```sh
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService all
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService contexts
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService connection
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService outbox
adb shell dumpsys activity service red.tix.tix_mobile/.adb.AdbService engine
```

| Section | Prints |
| --- | --- |
| (always) | Version and build, debug or release, which engine answered, theme, language, whether ADB control is on |
| `contexts` | The active context and every saved one: id (`<connection>.<tenant>`), instance, host or database file name, tenant, token or sign-in |
| `connection` | The live mode and the full Connection details report, as Copy details puts it on the clipboard |
| `outbox` | Per context: writes pending, refused, in conflict and to check, and open conflicts |
| `engine` | The active local instance and every engine that ran since the app started, with its state |

Sample:

```text
tix-mobile 0.8.0 (8), release build, app engine
Theme: system
Language: system
ADB control: off

[contexts]
Active: Work (tix.example.com) · Acme [s1.acme]
  * s1.acme  Work (tix.example.com) · Acme, sign-in
    l1.  Laptop (local tix.db), token
```

When the app is not open, a background engine starts to answer. The system gives `dumpsys` about two seconds, which
a cold start rarely makes, so the first run prints the version and the contexts the widgets know and says to run it
again; the background engine then stays up for a minute. It only reads what is stored: it never signs in, opens live
updates or starts a local engine, so `connection` and `engine` say so.

`dumpsys` finds the service only while the app's process runs. If it answers "No services match", wake the app
first with any [command](#commands), for example `help`, or open it.

## Links

`tix://` links open a screen. They never change data.

```sh
adb shell am start -a android.intent.action.VIEW -d "tix://inbox"
adb shell am start -a android.intent.action.VIEW -d "tix://mine"
adb shell am start -a android.intent.action.VIEW -d "tix://tasks"
adb shell am start -a android.intent.action.VIEW -d "'tix://tasks?filter=Due soon'"
adb shell am start -a android.intent.action.VIEW -d "tix://projects"
adb shell am start -a android.intent.action.VIEW -d "tix://projects/OPS"
adb shell am start -a android.intent.action.VIEW -d "tix://projects/OPS/tasks/OPS-12"
adb shell am start -a android.intent.action.VIEW -d "tix://settings"
adb shell am start -a android.intent.action.VIEW -d "tix://about"
adb shell am start -a android.intent.action.VIEW -d "tix://connection"
adb shell am start -a android.intent.action.VIEW -d "tix://quick-add"
adb shell am start -a android.intent.action.VIEW -d "'tix://quick-add?project=OPS'"
```

| Link | Opens |
| --- | --- |
| `tix://inbox` | Inbox |
| `tix://mine` | My work |
| `tix://tasks` | Tasks |
| `tix://tasks?filter=<name or id>` | Tasks, on that saved filter |
| `tix://projects` | Projects |
| `tix://projects/<KEY>` | The project's tasks |
| `tix://projects/<KEY>/tasks/<ref>` | The task |
| `tix://settings` | Settings |
| `tix://about` | About |
| `tix://watch` | Watch |
| `tix://connection` | Connection details, over the screen on show |
| `tix://quick-add` | Quick add over the screen on show; `?project=<KEY>` picks the project |

Add `?context=<id or name>` to switch context first. The name is matched, ignoring case, against the context id
from `dumpsys ... contexts`, the connection id, the instance name, the tenant's key or name, the connection's label,
or `<instance>/<tenant>`. Quote the link so the shell leaves the `?` alone:

```sh
adb shell am start -a android.intent.action.VIEW -d "'tix://projects/OPS?context=Work/acme'"
adb shell am start -a android.intent.action.VIEW -d "'tix://inbox?context=s1.acme'"
```

Naming the active context stays in it. A name that fits several other contexts opens a sheet asking which one; the
link goes nowhere if you cancel. A link the app does not know, or one naming no saved context, shows "Link not
recognised" and goes to the start screen. A link that arrives while nobody is signed in waits until a context is
active.

Links work in release builds and from any app, a browser included, which is why they only navigate. Quick add
opens the sheet and adds nothing until you do.

The app uses the same links itself. The Quick Settings tiles open `tix://quick-add` and
`tix://inbox?context=<id>`, and a project or saved filter added to the home screen (Add to home screen, where the
launcher supports pinned shortcuts) opens `tix://projects/<KEY>?context=<id>` or `tix://tasks?filter=<id>&context=<id>`,
so a shortcut made in one context keeps opening in it.

### Why not Flutter deep linking

Flutter's own deep linking (`flutter_deeplinking_enabled`) stays off. Turned on, it would push every launch URI to
the router as a path, including the widgets' `tixwidget://open?...` launches ([widgets.md](widgets.md#links)).
Instead `MainActivity` keeps the latest `tix://` VIEW intent, like a share, and hands it to Dart over the
`tix/links` channel; `DeepLinkHost`, around the signed-in screens, parses it and navigates with go_router. Widget
links, share intake and launcher shortcuts are untouched.

### iOS

Not yet. iOS would need the URL type in Info.plist and forwarding from the scene delegate, where `home_widget`
already handles widget URLs.

## Commands

```sh
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd help
```

`am broadcast` prints the answer as the result data (`result=0` worked, `result=1` did not), and the app logs it
under the `tix-adb` tag:

```sh
adb logcat -s tix-adb
```

The argument goes in the extra the command names, or after the name: `--es cmd "theme dark"` is the same as
`--es cmd theme --es value dark`. Quote anything with spaces twice, once for your shell and once for the phone's.

```sh
# What is there
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd help

# The dumpsys report, to logcat and the result data; --es section as for dumpsys
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd dump
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd dump --es section outbox

# Try live updates again at once (Reconnect now)
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd reconnect

# Send the outbox now
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd sync-now

# Switch context, by id or name as for links
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd switch --es context s1.acme
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd switch --es context Home

# Add a task in the active context; the server parses the line. Without --es project it goes to the first project
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd quick-add \
  --es line '"Renew the TLS cert !high due:fri"' --es project OPS

# Open a link
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd open \
  --es link tix://projects/OPS/tasks/OPS-12

# The active local instance's engine
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd engine-stop
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd engine-start

# Forget the saved copies (the response cache) of the active context; waiting writes are kept
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd clear-cache

# Theme: system, light, dark or oled
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd theme --es value dark

# Language: system, en, fr, de or bg
adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB --es cmd locale --es value bg
```

| Command | Extra | Does |
| --- | --- | --- |
| `help` | | Lists the commands |
| `dump` | `section` (optional) | Prints the [dumpsys](#reading-state-with-dumpsys) report |
| `reconnect` | | Tries live updates again at once |
| `sync-now` | | Replays the outbox and says what was sent, in conflict or refused |
| `switch` | `context` | Switches context; a name fitting several lists their ids instead |
| `quick-add` | `line`, `project` (optional) | Adds a task through quick add, parsed by the server |
| `open` | `link` | Opens a `tix://` link |
| `engine-stop` | | Stops (rests) the active local instance's engine |
| `engine-start` | | Starts it again |
| `clear-cache` | | Forgets the active context's saved copies |
| `theme` | `value` | Sets the theme |
| `locale` | `value` | Sets the language |

When the app is not open, `help`, `dump`, `theme`, `locale` and `open` run in a background engine. The rest need
the signed-in app, so tix brings itself up and runs them there. Android may stop an app in the background from
showing itself, which `open` and those commands need; if tix does not come up, or the answer says it could not be
brought up, open it first or add `--allow-background-activity-starts` to `am broadcast`.

## Security

- **Only the shell can command.** The receiver is exported but requires `android.permission.DUMP` of the sender.
  The shell (`adb`) holds it; ordinary apps cannot be granted it. The service is not exported: only the system calls
  its `dump()`, and `dumpsys` itself needs DUMP.
- **Release builds ask first.** Debug builds run every command. Release and profile builds run `help` and `dump`,
  which only read, and answer everything else with
  `disabled: enable Settings > Advanced > Allow control over ADB` until that switch is on. It is off by default and
  kept on this device only.
- **No secrets.** No command takes a credential, and an extra named `token`, `password`, `secret`, `cookie`,
  `session` or similar is refused. Every answer and report goes through the same redaction as the connection
  details, with the saved tokens and sessions on top: no token, password, cookie or URL query is printed. Contexts
  are listed by name and host; a local database by its file name only.
- **Links only navigate.** Anyone can open a `tix://` link, from a browser too, so links never change data. Switching
  context through one changes which context is shown, and asks when the name is ambiguous.
