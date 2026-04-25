# Project Structure

This project is split so Qt Design Studio and Qt Creator can work side by side without fighting each other.

## Top-level folders

- `app/`
  - Runtime entrypoint and application wiring.
  - Starts the app, registers runtime-only QML types, and injects context properties.
  - Main files:
    - `app/main.cpp`
    - `app/app_environment.h`

- `ui/`
  - Everything related to the QML user interface and Design Studio workflow.
  - This is the folder you should think of as the "frontend" of the project.

- `integrations/`
  - External subsystem integrations and backend-style code.
  - Current integration:
    - `integrations/carplay/`

- `cmake/`
  - CMake helper includes used by the runtime build.

- `docs/`
  - Project notes and workflow documentation.

## UI layout

- `ui/content/`
  - Main QML application screens, pages, and components.
  - Owned primarily by Qt Design Studio.

- `ui/imports/Rx8_HeadUnit/`
  - Shared design-time QML module generated/used by Design Studio.

- `ui/imports/CarPlay/`
  - Preview-only stub module so Qt Design Studio can load `import CarPlay 1.0`
    without needing the real runtime C++ backend.

- `ui/assets/`
  - UI-side configuration files such as `qtquickcontrols2.conf`.

- `ui/asset_imports/`
  - Asset-import folder used by Qt Design Studio.

## Runtime and CarPlay split

- Runtime app startup lives in `app/`.
- Real CarPlay backend and rendering lives in `integrations/carplay/`.
- Qt Creator build uses the real C++ backend.
- Qt Design Studio preview uses the stub module under `ui/imports/CarPlay/`.

## Practical editing rules

- Use **Qt Design Studio** for files under `ui/content/` and `ui/imports/`.
- Use **Qt Creator** for C++, build files, and runtime integration work.
- Keep `.ui.qml` files visual and declarative.
- Keep runtime logic in regular `.qml` files and C++.

## Dual-tooling note

This repository is maintained to stay compatible with both **Qt Creator** (runtime build) and **Qt Design Studio** (UI editing). See `docs/DUAL_TOOLING_WORKFLOW.md` for the rules that must be preserved during future edits.

