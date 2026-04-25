# Dual Tooling Workflow (Qt Creator + Qt Design Studio)

This project is structured so that:

- **Qt Creator** builds and runs the full app with the C++ backend and CarPlay integration.
- **Qt Design Studio** edits and previews the UI using QML-only preview-safe components.

## Source of truth

### Runtime / compiled app
- `CMakeLists.txt`
- `app/`
- `integrations/`
- `main.qml`
- `cmake/`

### UI / Design Studio
- `Rx8_HeadUnit.qmlproject`
- `ui/content/`
- `ui/imports/`
- `ui/asset_imports/`
- `ui/assets/`

## Compatibility rules

1. **Do not import C++-only types directly into Design Studio forms unless there is a matching QML preview stub.**
   - Runtime type: `integrations/carplay/CarPlayView.h`
   - Preview stub: `ui/imports/CarPlay/CarPlayView.qml`

2. **The preview stub must keep the same public QML-facing properties used by runtime QML.**
   Currently this includes:
   - `frame`
   - `engine`
   - `hasFrame`

3. **Keep logic in `.qml` files and keep `.ui.qml` files declarative.**
   - `.ui.qml` = layout and visual structure only
   - `.qml` = behavior, bindings, signals, runtime logic

4. **Do not move generated Qt Design Studio module folders casually.**
   - `ui/content`
   - `ui/imports`
   - `cmake/QmlModules.cmake`
   - `ui/content/CMakeLists.txt`
   - `ui/imports/*/CMakeLists.txt`

5. **Preserve import paths across both tools.**
   - C++ runtime import paths are set in `app/main.cpp`
   - Design Studio import paths are set in `Rx8_HeadUnit.qmlproject`

6. **Any new backend-backed QML type must have a preview strategy before merging.**
   Choose one of:
   - a QML stub in `ui/imports/...`
   - guarded usage via `typeof someContextProperty !== "undefined"`
   - a separate preview-only wrapper component

7. **Do not commit local build output into the project snapshot.**
   Exclude:
   - `build/`
   - `.qtcreator/`
   - other machine-local generated directories

## Recommended editing workflow

### UI changes
- Edit forms in Qt Design Studio.
- Keep preview dependencies QML-only.
- Test the edited screen in Design Studio preview first.
- Then verify the compiled app in Qt Creator.

### Backend changes
- Edit C++ and CMake in Qt Creator.
- If QML-facing properties/signals/types change, immediately update any preview stub under `ui/imports/`.

## CarPlay-specific rule

`AppleCarPlay.qml` depends on runtime objects that do not exist inside Qt Design Studio.
This is intentional. The screen must remain preview-safe by:

- guarding access to `carPlayEngine`
- guarding access to `carPlaySettingsPath`
- using the QML preview stub `ui/imports/CarPlay/CarPlayView.qml`

If the runtime `CarPlayView` QML API changes, update the preview stub in the same commit.
