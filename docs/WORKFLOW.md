# Recommended Workflow

## Qt Design Studio

Open `Rx8_HeadUnit.qmlproject` when you want to work on layout, styling, and page structure.

Primary folders:
- `ui/content/`
- `ui/imports/`
- `ui/assets/`

Design Studio does not need the real C++ CarPlay backend to preview the CarPlay page.
It will use the preview stub from `ui/imports/CarPlay/`.

## Qt Creator

Open `CMakeLists.txt` when you want to build and run the full application.

Primary folders:
- `app/`
- `integrations/`
- `cmake/`
- `ui/`

Qt Creator runs the real app and the real CarPlay integration.
Any QML changes made in `ui/content/` are reflected when you rebuild/run in Qt Creator.
