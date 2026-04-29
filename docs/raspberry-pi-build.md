# Raspberry Pi Build

This project is a Qt 6/QML CMake application with native CarPlay dependencies.
The QML imports currently target Qt 6.8, so use a Raspberry Pi OS image or Qt
installation that provides Qt 6.8 or newer.

## Recommended Pi Setup

Use a 64-bit Raspberry Pi OS or Debian image. If you are on Bookworm, the distro
Qt packages are usually Qt 6.4 and are too old for the current QML imports. Use
Debian/Raspberry Pi OS Trixie packages, or install Qt 6.8+ from Qt.

Install the native build dependencies:

```bash
sudo apt update
sudo apt install -y \
  build-essential cmake ninja-build pkg-config xxd git \
  libssl-dev libusb-1.0-0-dev \
  libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev
```

Install Qt 6.8+ development packages. On a Qt 6.8 based distro this is typically:

```bash
sudo apt install -y \
  qt6-base-dev qt6-declarative-dev qt6-multimedia-dev \
  qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-layouts \
  qml6-module-qtquick-window qml6-module-qtmultimedia
```

If Qt is installed somewhere custom, set `CMAKE_PREFIX_PATH` to that Qt install:

```bash
export CMAKE_PREFIX_PATH=/opt/Qt/6.8.*/gcc_arm64
```

## Build

From the project root on the Pi, with source in `Dev` and Raspberry Pi build
files in `build-rpi`:

```bash
cmake -S Dev -B build-rpi -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_QDS_COMPONENTS=OFF \
  -DLINK_INSIGHT=OFF
cmake --build build-rpi -j"$(nproc)"
```

Run it from the build directory:

```bash
./build-rpi/Rx8_HeadUnitApp
```

## Display Runtime Notes

On Raspberry Pi OS Desktop or Wayland, try the app directly first. For a kiosk or
head-unit style launch, these environment variables are useful:

```bash
export QT_QPA_PLATFORM=wayland
export QT_ENABLE_HIGHDPI_SCALING=0
./build-rpi/Rx8_HeadUnitApp
```

If Wayland gives trouble, try X11:

```bash
export QT_QPA_PLATFORM=xcb
./build-rpi/Rx8_HeadUnitApp
```

For direct display without a desktop session, Qt's `eglfs` platform can work if
the installed Qt build includes the EGLFS plugin:

```bash
export QT_QPA_PLATFORM=eglfs
./build-rpi/Rx8_HeadUnitApp
```

## USB Permissions For CarPlay

The CarPlay path uses `libusb`. If the app builds but cannot access the USB
device, add a udev rule for the adapter's vendor/product ID after identifying it
with `lsusb`.

Example template:

```bash
sudo tee /etc/udev/rules.d/99-rx8-carplay.rules >/dev/null <<'RULE'
SUBSYSTEM=="usb", ATTR{idVendor}=="1234", ATTR{idProduct}=="5678", MODE="0660", GROUP="plugdev", TAG+="uaccess"
RULE
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Replace `1234` and `5678` with the actual IDs from `lsusb`.
