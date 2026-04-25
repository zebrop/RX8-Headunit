# Rx8 HeadUnit

This repository is organized so the same UI can be edited in **Qt Design Studio** and then built and run in **Qt Creator**.

## Folder guide

- `app/` — runtime application entrypoint and startup wiring
- `ui/` — QML UI, Design Studio content, preview imports, and UI-side assets
- `integrations/` — backend/integration code such as CarPlay
- `cmake/` — helper CMake include files
- `docs/` — project, workflow, deployment, and SDL-removal notes

## Open in Qt Design Studio

Open:
- `Rx8_HeadUnit.qmlproject`

Main working area:
- `ui/content/`
- `ui/imports/`

## Open in Qt Creator

Open:
- `CMakeLists.txt`

Main working area:
- `app/`
- `integrations/`
- `ui/`

## CarPlay split

- Runtime app uses the real C++ CarPlay integration from `integrations/carplay/`
- Design Studio preview uses the stub module in `ui/imports/CarPlay/`

## Notes

- Build output and local editor folders should stay out of the repo and release zips.
- CarPlay settings are copied to the build output under `carplay/settings.txt`.
- Detailed CarPlay timing logs can be controlled with the CMake option `RX8_ENABLE_CARPLAY_DIAGNOSTICS`.
