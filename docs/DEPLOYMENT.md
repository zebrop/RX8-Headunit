# Deployment Notes

## CarPlay settings file

The runtime now looks for `settings.txt` in this order:

1. next to the executable: `settings.txt`
2. next to the executable under `carplay/settings.txt`
3. app config directory returned by `QStandardPaths::AppConfigLocation`
4. app config directory under `carplay/settings.txt`
5. legacy developer relative path: `../../integrations/carplay/fastcarplay/settings.txt`
6. macOS-style resources fallback: `../Resources/settings.txt`

During a normal CMake build, the default settings file is copied to:

- `<build output>/carplay/settings.txt`

This keeps development working while making packaging more predictable.

## Recommended repo contents

Keep these in source control:
- `app/`
- `ui/`
- `integrations/`
- `cmake/`
- `docs/`
- project files and resource files

Do not keep these in source control or release zips:
- `build/`
- `.qtcreator/`
- `*.user`
- local cache/output files
