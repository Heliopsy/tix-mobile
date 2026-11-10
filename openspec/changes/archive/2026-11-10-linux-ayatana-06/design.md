# Design

## Build only the library

Upstream's `src/CMakeLists.txt` always generates the GObject introspection data, with no option to turn it off. Its
find module does not fail when `g-ir-scanner` is missing, so configuring works without it, and building only the
`ayatana-appindicator3` target skips the `.gir` and typelib. The script then installs the one shared object under
its soname rather than running `cmake --install`, which would try to install the introspection files.

## Same soname, older headers

0.6.1 keeps `SOVERSION 1`, so the tray plugin, compiled against Ubuntu's 0.5 headers, loads the 0.6 copy. The
plugin does not subclass `AppIndicator`, so the class struct gaining a `new_tooltip` slot does not matter. The
runner sets the tooltip through GObject properties found at run time, never through 0.6-only functions, so the build
needs no 0.6 headers.

## Cache

The prefix is restored with `actions/cache/restore` and saved on a push to main only, as the libtix cache is. The
key carries the version, the runner image, the architecture and a hash of the script, so a new pin or new build
flags rebuild it. The script is a no-op when the prefix already holds the pinned version and checksum.
