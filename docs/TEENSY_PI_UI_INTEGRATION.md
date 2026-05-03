# Teensy numeric UART integration

The Qt app now reads the new Teensy numeric Pi stream:

```text
V,key,value
INFO,key,value
```

Commands from the UI are sent back to the Teensy as:

```text
C,command
```

Default Pi serial port order is:

1. `RX8_TEENSY_PORT` environment variable
2. `/dev/ttyAMA0`
3. `/dev/ttyAMA10`
4. `/dev/serial0`
5. `/dev/ttyUSB0`
6. `/dev/ttyACM0`
7. Any Qt-detected serial ports

For the Raspberry Pi 5 UART that already worked in testing, run with:

```bash
export RX8_TEENSY_PORT=/dev/ttyAMA0
/opt/Rx8_HeadUnit/launch.sh
```

## A/C page mapping

The A/C page is telemetry-driven. Button/lamp state is taken from the A/C amplifier status values, not from remembered button presses.

| Teensy key | UI use |
| --- | --- |
| `ac_rx_valid` | Enables/disables live A/C controls |
| `ac_temp` | Temperature slider/text |
| `ac_fan` | Fan slider/text and power state |
| `ac_mode` | Face/Feet/Face+Feet/Feet+Demist/Front Demist buttons |
| `ac_auto` | Auto button light |
| `ac_compressor` | A/C button light |
| `ac_air_source` | Fresh/recirc switch, `0=recirc`, `1=fresh` |
| `ac_front_demist` | Front demist state via mode button |
| `ac_rear_demist` | Rear demist button light |
| `ac_eco` | ECO lamp |
| `ac_running` | Normal lamp |
| `ac_amp_ambient` | Ambient lamp |

`ac_mode` mapping:

```text
0 unknown
1 feet
2 feet + demist
3 face
4 face + feet
5 front demist
```

## Performance page mapping

The performance page now consumes live values from the Teensy stream:

| Teensy key | UI use |
| --- | --- |
| `rpm` | Tachometer and RPM text |
| `speed_kmh` | Vehicle speed |
| `throttle_pedal_percent` | Throttle position text/bar |
| `coolant_c` | Coolant temperature |
| `iat_c` | Intake air temperature |
| `battery_v` | Voltage |
| `fuel_level_percent` | Fuel bar/percent |
| `actual_afr` | AFR field |
| `maf_gps` | MAF field |
| `inst_l_100km` | Instant fuel economy while moving |
| `inst_l_h` | Fuel flow while stopped/slow |
| `inst_fuel_mode` | `0=L/100km`, `1=L/h` |
| `road_wheel_est_deg` | Front wheel angle overlay |
| `wheel_fl_kmh`, `wheel_fr_kmh`, `wheel_rl_kmh`, `wheel_rr_kmh` | Wheel speed overlay |

Average fuel economy is left as `--` because the current Teensy sketch only sends instant economy/fuel-flow values.

## Build locally on Linux

```bash
./scripts/build-local-linux.sh
RX8_TEENSY_PORT=/dev/ttyUSB0 ./build-local/Rx8_HeadUnitApp
```

Qt Creator can also open the root `CMakeLists.txt` and use a local build folder such as `build-local`.

## Raspberry Pi 5 packages

Install the serial-port development package as well as the existing Qt/FFmpeg/USB dependencies:

```bash
sudo apt update
sudo apt install -y cmake ninja-build pkg-config rsync \
  qt6-base-dev qt6-declarative-dev qt6-multimedia-dev qt6-serialport-dev \
  libusb-1.0-0-dev libssl-dev libavcodec-dev libavformat-dev libavutil-dev \
  libswscale-dev libswresample-dev
```

Package names can vary slightly by distro image. If `qt6-serialport-dev` is missing, search with `apt-cache search qt6 serialport`.

## Build/install on Raspberry Pi 5 over SSH

Defaults match your Pi SSH details:

```bash
./scripts/build-pi-ssh.sh
ssh brad@172.20.10.9 /opt/Rx8_HeadUnit/launch.sh
```

Override details if needed:

```bash
PI_USER=brad PI_HOST=172.20.10.9 PI_PROJECT_DIR=/home/brad/Projects/RX8_HeadUnit ./scripts/build-pi-ssh.sh
```

The script syncs this project to the Pi, excludes local build folders, builds in `build-rpi`, and installs to `/opt/Rx8_HeadUnit`.

## Design Studio compatibility

Design Studio still edits the QML files and uses the existing QML-only CarPlay stub module. The telemetry object is resolved defensively in QML, so Design Studio can preview pages without the C++ `teensyGateway` context object.
