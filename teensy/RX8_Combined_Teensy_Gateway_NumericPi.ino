#define acAmpRX 28
#define acAmpTX 29

#include <Arduino.h>
#include <FlexCAN_T4.h>

// ======================================================
// RX-8 Combined Teensy Gateway
// Teensy 4.1
//
// USB Serial:
//   Debug dashboard / commands
//
// Raspberry Pi UART:
//   Serial8 RX = Teensy pin 34
//   Serial8 TX = Teensy pin 35
//   3.3 V UART, no level shifter needed to Pi GPIO UART
//
// A/C Amplifier:
//   Serial7 RX = Teensy pin 28
//   Serial7 TX = Teensy pin 29
//   4800 baud, 8E1, inverted RX/TX
//
// CAN:
//   CAN3 RX = Teensy pin 30
//   CAN3 TX = Teensy pin 31
//   500 kbps
//
// Pi protocol:
//   Teensy -> Pi:
//     V,key,value
//
//   IMPORTANT:
//     All V values are numeric only.
//     bool values: 0 = false/off/no, 1 = true/on/yes
//     enum/status values: see mapping comments beside each decoder.
//
//   Pi -> Teensy:
//     C,command
//
// Example Pi commands:
//   C,fanup
//   C,fandown
//   C,tempup
//   C,tempdown
//   C,face
//   C,feet
//   C,facefeet
//   C,feetdemist
//   C,demist
//   C,ac
//   C,auto
//   C,off
//   C,airsource
//   C,frontdemist
//   C,reardemist
// ======================================================


// ======================================================
// User config
// ======================================================

#define SERIAL_BAUD 1000000
#define CAN_BAUD    500000

#define PI_LINK_SERIAL Serial8
#define PI_LINK_BAUD   1000000

#define ENABLE_PI_LINK_STREAM 1

// USB dashboard for debugging.
// Set to 0 if you only want Pi stream and no USB dashboard redraw.
#define ENABLE_USB_DASHBOARD 1

// Set to 1 if using terminal/screen/picocom.
// Set to 0 if Arduino Serial Monitor looks messy.
#define USE_ANSI_DASHBOARD 1

#define DASHBOARD_REFRESH_MS 150
#define PI_AC_STREAM_INTERVAL_MS 150
#define FUEL_CALC_INTERVAL_MS 100

// Petrol/gasoline constants
#define PETROL_DENSITY_G_PER_L 745.0f
#define PETROL_STOICH_AFR      14.7f
#define MIN_L100_SPEED_KMH     5.0f

// OBD/CAN config
#define OBD_FUNCTIONAL_REQUEST_ID 0x7DF
#define OBD_PHYSICAL_REQUEST_ID   0x7E0
#define DIAG_RESPONSE_MIN_ID      0x7E8
#define DIAG_RESPONSE_MAX_ID      0x7EF

// Set to 1 if functional 0x7DF does not work well.
#define USE_PHYSICAL_OBD_ID 0

// Lower = faster polling, but too low can cause missing valid responses.
#define RESPONSE_TIMEOUT_US 12000UL

#define FAIL_THRESHOLD 2
#define SKIP_CYCLES   64

#define STEERING_RATIO 16.4f


// ======================================================
// CAN setup
// ======================================================

FlexCAN_T4<CAN3, RX_SIZE_256, TX_SIZE_16> Can3;
CAN_message_t msg;


// ======================================================
// A/C Amplifier TX data
// ======================================================

byte acAmpDataOut[5];

const byte acAmpDataDefault[5] = {
  0x04, 0x80, 0x80, 0x80, 0xFC
};

unsigned long acAmpTxBetweenTime = 0;
const unsigned long acAmpTxWaitTime = 18;


// ======================================================
// A/C Amplifier RX data
// ======================================================

byte acAmpIndex = 0;
byte acAmpNewByte = 0;
byte acAmpRxData[6];
byte acAmpRxDataLast[6];

bool acAmpRxPacketValid = false;
bool acAmpRxLastValid = false;


// ======================================================
// A/C command state
// ======================================================

bool sendCustomPacket = false;
String pendingCommand = "";

bool printNextStatusChange = false;


// ======================================================
// Vent mode targeting
// ======================================================

// Numeric mapping sent to Pi as ac_mode:
//   0 = unknown
//   1 = feet
//   2 = feet + demist
//   3 = face
//   4 = face + feet
//   5 = front demist
enum VentMode : byte {
  VENT_UNKNOWN = 0,
  VENT_FEET = 1,
  VENT_FEET_DEMIST = 2,
  VENT_FACE = 3,
  VENT_FACE_FEET = 4,
  VENT_FRONT_DEMIST = 5
};

VentMode requestedVentMode = VENT_UNKNOWN;

unsigned long lastModeStepTime = 0;
const unsigned long modeStepWaitTime = 220;

byte modeStepCount = 0;
const byte modeStepMax = 10;


// ======================================================
// CAN diagnostic PID setup
// ======================================================

enum RequestType {
  REQ_OBD01,
  REQ_UDS22
};

struct PIDDef {
  RequestType type;
  uint16_t id;
  const char *key;
};

PIDDef pids[] = {
  // OBD Mode 01
  {REQ_OBD01, 0x0003, "fuel_system_status"},
  {REQ_OBD01, 0x0005, "coolant_c"},
  {REQ_OBD01, 0x0006, "stft_percent"},
  {REQ_OBD01, 0x0007, "ltft_percent"},
  {REQ_OBD01, 0x000E, "ign_timing_deg"},
  {REQ_OBD01, 0x000F, "iat_c"},
  {REQ_OBD01, 0x0010, "maf_gps"},
  {REQ_OBD01, 0x0011, "throttle_pos_percent"},
  {REQ_OBD01, 0x0015, "rear_o2_v_trim"},
  {REQ_OBD01, 0x002E, "evap_purge_percent"},
  {REQ_OBD01, 0x002F, "fuel_level_percent"},
  {REQ_OBD01, 0x0033, "baro_kpa"},
  {REQ_OBD01, 0x0034, "front_wideband_lambda_ma"},
  {REQ_OBD01, 0x003C, "cat_temp_c"},
  {REQ_OBD01, 0x0042, "battery_v"},
  {REQ_OBD01, 0x0044, "cmd_equiv_ratio"},
  {REQ_OBD01, 0x0045, "relative_throttle_percent"},
  {REQ_OBD01, 0x0047, "absolute_throttle_percent"},
  {REQ_OBD01, 0x0049, "app_sensor_1_percent"},
  {REQ_OBD01, 0x004A, "app_sensor_2_percent"},
  {REQ_OBD01, 0x004C, "cmd_throttle_actuator_percent"},

  // Mazda/RX-8 0x22 DIDs
  {REQ_UDS22, 0x0904, "trailing_ign_timing_deg"},
  {REQ_UDS22, 0x0914, "app_v_1"},
  {REQ_UDS22, 0x0915, "app_v_2"},
  {REQ_UDS22, 0x0917, "tp_v_1"},
  {REQ_UDS22, 0x0918, "tp_v_2"},
  {REQ_UDS22, 0x091A, "target_throttle_angle_raw256"},
  {REQ_UDS22, 0x093C, "throttle_angle_raw256"},
  {REQ_UDS22, 0x0968, "generator_engine_flag"},
  {REQ_UDS22, 0x09D3, "vfad_status"},
  {REQ_UDS22, 0x1103, "apv_position_status"},
  {REQ_UDS22, 0x1104, "ac_relay"},
  {REQ_UDS22, 0x114D, "pcm_temp_v"},
  {REQ_UDS22, 0x1154, "tp_sensor_1_main_percent"},
  {REQ_UDS22, 0x1410, "fuel_injection_ms"},
  {REQ_UDS22, 0x1631, "o2_heater_status"},
  {REQ_UDS22, 0x1634, "apv_position_sensor_v"},
  {REQ_UDS22, 0x1688, "air_solenoid"},
  {REQ_UDS22, 0x16E8, "target_generator_v"},
  {REQ_UDS22, 0x1706, "omp_switch"},
  {REQ_UDS22, 0x1711, "fuel_pump_speed_relay"},
  {REQ_UDS22, 0x1715, "vdi_status"},
  {REQ_UDS22, 0x1718, "fuel_pump_relay"},
  {REQ_UDS22, 0x172D, "omp_position_percent"},
  {REQ_UDS22, 0x1746, "knock_retard_deg"},
  {REQ_UDS22, 0x17C8, "vfad_iasv_enable"},
  {REQ_UDS22, 0xA211, "gear_clutch_state"},
};

const int PID_COUNT = sizeof(pids) / sizeof(pids[0]);

static uint8_t failStreak[PID_COUNT];
static uint8_t skipCounter[PID_COUNT];
static int nextPollIndex = 0;


// ======================================================
// Value storage
// ======================================================

struct ValueSlot {
  const char *key;
  char value[28];
  uint32_t lastUpdateMs;
  bool valid;
};

#define MAX_VALUES 120

ValueSlot values[MAX_VALUES];
int valueCount = 0;


// ======================================================
// Pi stream + fuel economy state
// ======================================================

unsigned long lastPiAcStreamMs = 0;
unsigned long lastFuelCalcMs = 0;
unsigned long lastDashboardMs = 0;
unsigned long lastCommandMs = 0;

char lastCommandText[48] = "none";
char lastEventText[96] = "starting";

float latestSpeedKmh = 0.0f;
float latestMafGps = 0.0f;
float latestActualLambda = 1.0f;
float latestCommandedLambda = 1.0f;
float latestActualAfr = PETROL_STOICH_AFR;
float latestCommandedAfr = PETROL_STOICH_AFR;

bool haveSpeedKmh = false;
bool haveMafGps = false;
bool haveActualLambda = false;
bool haveCommandedLambda = false;
bool haveActualAfr = false;
bool haveCommandedAfr = false;


// ======================================================
// Forward declarations
// ======================================================

void acAmpGetSerialData();
void acAmpSend();
void checkAndSendHardwareControl();
void readSerialCommands();
void processAButtonCommand(String cmd);

void setDefaultPacket();
void setCommandPacket(byte b1, byte b2, byte b3);
void setModeButtonPacket();
void setFrontDemistButtonPacket();
byte acAmpChecksum(byte b0, byte b1, byte b2, byte b3);

bool acAmpPacketChanged();
void rememberAcPacket();

VentMode getCurrentVentMode();
const char* ventModeName(VentMode mode);
void requestVentMode(VentMode mode);
void handleRequestedVentMode();

byte getFanSpeed();
byte getTempDigit1();
byte getTempDigit2();
byte getTempDigit3();

bool getAutoState();
bool getAcState();
bool getEcoState();
bool getFreshAirState();
bool getRecircState();
bool getFrontDemistState();
bool getRearDemistState();
bool getAcAmpOnState();
bool getAcAmpAmbientState();
bool getAcAmpRunningState();

int findValueSlot(const char *key);
void updateValueText(const char *key, const char *text);
void updateValueFloat(const char *key, float value, int decimals);
const char* getValueText(const char *key, const char *fallback);
uint32_t getValueAge(const char *key);

void drawDashboard();
void printHelp();
void printCurrentStatusText();

void piBegin();
void piReadCommands();
void processIncomingCommandLine(String line);
void piSendValueText(const char *key, const char *value);
void piSendValueFloat(const char *key, float value, int decimals);
void piSendValueInt(const char *key, int32_t value);
void piSendAcStatus();
void updateFuelEconomy();

static void drainCanRx();
static void processPassiveFrame(const CAN_message_t &m);
static int pollOne(const PIDDef &d);


// ======================================================
// Setup
// ======================================================

void setup() {
  Serial.begin(SERIAL_BAUD);
  Serial.setTimeout(5);

  PI_LINK_SERIAL.begin(PI_LINK_BAUD);
  PI_LINK_SERIAL.setTimeout(5);

  Serial7.begin(4800, SERIAL_8E1_RXINV_TXINV);

  setDefaultPacket();

  memset(acAmpRxData, 0, sizeof(acAmpRxData));
  memset(acAmpRxDataLast, 0, sizeof(acAmpRxDataLast));

  Can3.begin();
  Can3.setBaudRate(CAN_BAUD);
  Can3.setMaxMB(64);
  Can3.enableFIFO();
  Can3.setFIFOFilter(ACCEPT_ALL);
  Can3.setMBFilter(ACCEPT_ALL);

  delay(300);

#if ENABLE_USB_DASHBOARD && USE_ANSI_DASHBOARD
  Serial.print("\033[2J\033[H\033[?25l");
#endif

  Serial.println("RX-8 Combined Teensy Gateway Ready");
  Serial.println("USB: dashboard/debug");
  Serial.println("Pi UART: Serial8, V,key,value stream");
  Serial.println("Type 'help' for commands.");

  piBegin();

  delay(700);
}


// ======================================================
// Main loop
// ======================================================

void loop() {
  readSerialCommands();
  piReadCommands();

  checkAndSendHardwareControl();
  acAmpGetSerialData();

  Can3.events();

  if (nextPollIndex >= PID_COUNT) {
    nextPollIndex = 0;
  }

  int idx = nextPollIndex++;

  if (skipCounter[idx] > 0) {
    --skipCounter[idx];
    drainCanRx();
  } else {
    int result = pollOne(pids[idx]);

    if (result == -1) {
      if (++failStreak[idx] >= FAIL_THRESHOLD) {
        failStreak[idx] = 0;
        skipCounter[idx] = SKIP_CYCLES;
      }
    } else {
      failStreak[idx] = 0;
    }
  }

  if (millis() - lastFuelCalcMs >= FUEL_CALC_INTERVAL_MS) {
    updateFuelEconomy();
    lastFuelCalcMs = millis();
  }

  if (millis() - lastPiAcStreamMs >= PI_AC_STREAM_INTERVAL_MS) {
    piSendAcStatus();
    lastPiAcStreamMs = millis();
  }

#if ENABLE_USB_DASHBOARD
  if (millis() - lastDashboardMs >= DASHBOARD_REFRESH_MS) {
    drawDashboard();
    lastDashboardMs = millis();
  }
#endif
}


// ======================================================
// Value storage
// ======================================================

int findValueSlot(const char *key) {
  for (int i = 0; i < valueCount; i++) {
    if (strcmp(values[i].key, key) == 0) {
      return i;
    }
  }

  if (valueCount < MAX_VALUES) {
    values[valueCount].key = key;
    values[valueCount].value[0] = '\0';
    values[valueCount].lastUpdateMs = 0;
    values[valueCount].valid = false;
    valueCount++;
    return valueCount - 1;
  }

  return -1;
}


void updateValueText(const char *key, const char *text) {
  // USB dashboard/debug storage only.
  // Do NOT stream this to the Pi because Pi telemetry values are numeric-only.
  int idx = findValueSlot(key);
  if (idx < 0) return;

  strncpy(values[idx].value, text, sizeof(values[idx].value) - 1);
  values[idx].value[sizeof(values[idx].value) - 1] = '\0';
  values[idx].lastUpdateMs = millis();
  values[idx].valid = true;
}


void updateValueFloat(const char *key, float value, int decimals) {
  int idx = findValueSlot(key);
  if (idx < 0) return;

  snprintf(values[idx].value, sizeof(values[idx].value), "%.*f", decimals, (double)value);
  values[idx].lastUpdateMs = millis();
  values[idx].valid = true;

  if (strcmp(key, "speed_kmh") == 0) {
    latestSpeedKmh = value;
    haveSpeedKmh = true;
  } else if (strcmp(key, "maf_gps") == 0) {
    latestMafGps = value;
    haveMafGps = true;
  } else if (strcmp(key, "actual_lambda") == 0) {
    latestActualLambda = value;
    latestActualAfr = value * PETROL_STOICH_AFR;
    haveActualLambda = true;
    haveActualAfr = true;
  } else if (strcmp(key, "cmd_equiv_ratio") == 0 || strcmp(key, "commanded_lambda") == 0) {
    latestCommandedLambda = value;
    latestCommandedAfr = value * PETROL_STOICH_AFR;
    haveCommandedLambda = true;
    haveCommandedAfr = true;
  } else if (strcmp(key, "actual_afr") == 0) {
    latestActualAfr = value;
    haveActualAfr = true;
  } else if (strcmp(key, "commanded_afr") == 0) {
    latestCommandedAfr = value;
    haveCommandedAfr = true;
  }

#if ENABLE_PI_LINK_STREAM
  piSendValueFloat(key, value, decimals);
#endif
}


const char* getValueText(const char *key, const char *fallback) {
  for (int i = 0; i < valueCount; i++) {
    if (strcmp(values[i].key, key) == 0 && values[i].valid) {
      return values[i].value;
    }
  }

  return fallback;
}


uint32_t getValueAge(const char *key) {
  for (int i = 0; i < valueCount; i++) {
    if (strcmp(values[i].key, key) == 0 && values[i].valid) {
      return millis() - values[i].lastUpdateMs;
    }
  }

  return 0xFFFFFFFF;
}


// ======================================================
// USB dashboard
// ======================================================

void printKV(const char *label, const char *value, const char *unit = "") {
  Serial.print(label);

  int labelLen = strlen(label);
  for (int i = labelLen; i < 30; i++) {
    Serial.print(' ');
  }

  Serial.print(value);

  if (unit && unit[0] != '\0') {
    Serial.print(' ');
    Serial.print(unit);
  }

  Serial.println();
}


void printAcRaw() {
  if (!acAmpRxPacketValid) {
    Serial.print("-- -- -- -- -- --");
    return;
  }

  for (byte i = 0; i < 6; i++) {
    if (acAmpRxData[i] < 0x10) Serial.print("0");
    Serial.print(acAmpRxData[i], HEX);
    if (i < 5) Serial.print(" ");
  }
}


void drawDashboard() {
#if USE_ANSI_DASHBOARD
  Serial.print("\033[H");
  Serial.print("\033[2J");
#endif

  Serial.println("================================================================================");
  Serial.println(" RX-8 LIVE DASHBOARD - CAN3 + A/C AMP + PI UART STREAM");
  Serial.println("================================================================================");

  Serial.print("Uptime: ");
  Serial.print(millis() / 1000);
  Serial.print(" s");
  Serial.print("     Last command: ");
  Serial.print(lastCommandText);
  Serial.print("     Event: ");
  Serial.println(lastEventText);

  Serial.println();

  Serial.println("[ENGINE / PCM]");
  printKV("RPM", getValueText("rpm", "--"), "rpm");
  printKV("Speed", getValueText("speed_kmh", "--"), "km/h");
  printKV("Throttle pedal", getValueText("throttle_pedal_percent", "--"), "%");
  printKV("Coolant", getValueText("coolant_c", "--"), "C");
  printKV("IAT", getValueText("iat_c", "--"), "C");
  printKV("Battery", getValueText("battery_v", "--"), "V");
  printKV("MAF", getValueText("maf_gps", "--"), "g/s");
  printKV("Fuel level", getValueText("fuel_level_percent", "--"), "%");
  printKV("Ign timing leading", getValueText("ign_timing_deg", "--"), "deg");
  printKV("Ign timing trailing", getValueText("trailing_ign_timing_deg", "--"), "deg");
  printKV("Knock retard", getValueText("knock_retard_deg", "--"), "deg");

  Serial.println();

  Serial.println("[AFR / FUEL ECONOMY]");
  printKV("Actual lambda", getValueText("actual_lambda", "--"));
  printKV("Actual AFR", getValueText("actual_afr", "--"));
  printKV("Commanded lambda", getValueText("commanded_lambda", "--"));
  printKV("Commanded AFR", getValueText("commanded_afr", "--"));
  printKV("AFR used for fuel calc", getValueText("fuel_afr_used", "--"));
  printKV("Fuel flow", getValueText("fuel_lph", "--"), "L/h");
  printKV("Instant economy", getValueText("inst_l_100km", "--"), "L/100km");
  printKV("Stopped/idle economy", getValueText("inst_l_h", "--"), "L/h");
  printKV("Fuel display mode", getValueText("inst_fuel_mode", "--"));

  Serial.println();

  Serial.println("[CHASSIS]");
  printKV("Steering wheel", getValueText("steering_wheel_deg", "--"), "deg");
  printKV("Road wheel estimate", getValueText("road_wheel_est_deg", "--"), "deg");
  printKV("Wheel FL", getValueText("wheel_fl_kmh", "--"), "km/h");
  printKV("Wheel FR", getValueText("wheel_fr_kmh", "--"), "km/h");
  printKV("Wheel RL", getValueText("wheel_rl_kmh", "--"), "km/h");
  printKV("Wheel RR", getValueText("wheel_rr_kmh", "--"), "km/h");

  Serial.println();

  Serial.println("[A/C AMPLIFIER]");
  Serial.print("Raw RX                        ");
  printAcRaw();
  Serial.println();

  if (!acAmpRxPacketValid) {
    printKV("A/C RX", "waiting");
  } else {
    char tempBuf[12];
    snprintf(tempBuf, sizeof(tempBuf), "%u%u.%u",
             getTempDigit1(),
             getTempDigit2(),
             getTempDigit3());

    char fanBuf[12];
    byte fanSpeed = getFanSpeed();

    if (fanSpeed == 0) {
      strcpy(fanBuf, "off");
    } else {
      snprintf(fanBuf, sizeof(fanBuf), "%u / 7", fanSpeed);
    }

    const char *powerState = "unknown";
    if (acAmpRxData[0] == 0x0D) powerState = "normal";
    else if (acAmpRxData[0] == 0x0E) powerState = "ambient";
    else if (acAmpRxData[0] == 0x0F) powerState = "off / partial";

    printKV("Power/state", powerState);
    printKV("A/C amp on", getAcAmpOnState() ? "yes" : "no");
    printKV("Running/fan active", getAcAmpRunningState() ? "yes" : "no");
    printKV("Temperature", tempBuf, "C-ish");
    printKV("Fan speed", fanBuf);
    printKV("Vent mode", ventModeName(getCurrentVentMode()));
    printKV("Auto mode", getAutoState() ? "auto" : "manual");
    printKV("A/C compressor request", getAcState() ? "on" : "off");
    printKV("ECO", getEcoState() ? "on" : "off");
    printKV("Air source", getFreshAirState() ? "fresh" : "recirc");
    printKV("Front demist", getFrontDemistState() ? "on" : "off");
    printKV("Rear demist", getRearDemistState() ? "on" : "off");
  }

  Serial.println();

  Serial.println("[STATUS / EXTRA]");
  printKV("Fuel system", getValueText("fuel_system_status", "--"));
  printKV("Gear/clutch", getValueText("gear_clutch_state", "--"));
  printKV("A/C relay", getValueText("ac_relay", "--"));
  printKV("VDI", getValueText("vdi_status", "--"));
  printKV("VFAD", getValueText("vfad_status", "--"));
  printKV("Air solenoid", getValueText("air_solenoid", "--"));
  printKV("Fuel pump relay", getValueText("fuel_pump_relay", "--"));

  Serial.println("================================================================================");
  Serial.println("USB commands: help | status | fanup/fandown | tempup/tempdown | face/feet");
  Serial.println("              facefeet/feetdemist/demist | ac | auto | off | airsource");
  Serial.println("Pi commands:  C,fanup  C,tempdown  C,face  etc.");
  Serial.println("================================================================================");
}


// ======================================================
// A/C packet helpers
// ======================================================

void setDefaultPacket() {
  memcpy(acAmpDataOut, acAmpDataDefault, 5);
}


byte acAmpChecksum(byte b0, byte b1, byte b2, byte b3) {
  return (byte)((0x80 - ((b0 + b1 + b2 + b3) & 0xFF)) & 0xFF);
}


void setCommandPacket(byte b1, byte b2, byte b3) {
  acAmpDataOut[0] = 0x04;
  acAmpDataOut[1] = b1;
  acAmpDataOut[2] = b2;
  acAmpDataOut[3] = b3;
  acAmpDataOut[4] = acAmpChecksum(acAmpDataOut[0], b1, b2, b3);
}


void setModeButtonPacket() {
  setCommandPacket(0x90, 0x80, 0x80);
}


void setFrontDemistButtonPacket() {
  setCommandPacket(0xA0, 0x80, 0x80);
}


// ======================================================
// A/C receive
// ======================================================

void acAmpGetSerialData() {
  while (Serial7.available() > 0) {
    acAmpNewByte = Serial7.read();

    // Known first byte values from A/C amplifier:
    // 0x0D = normal
    // 0x0E = ambient
    // 0x0F = off / partial state
    if (acAmpNewByte == 0x0F || acAmpNewByte == 0x0D || acAmpNewByte == 0x0E) {
      acAmpIndex = 0;
      acAmpRxData[acAmpIndex] = acAmpNewByte;
    } else {
      acAmpIndex++;

      if (acAmpIndex >= 6) {
        acAmpIndex = 0;
        acAmpRxPacketValid = false;
        return;
      }

      acAmpRxData[acAmpIndex] = acAmpNewByte;

      if (acAmpIndex == 5) {
        acAmpRxPacketValid = true;

        if (acAmpPacketChanged()) {
          rememberAcPacket();
          snprintf(lastEventText, sizeof(lastEventText), "A/C status changed");
        } else if (printNextStatusChange) {
          snprintf(lastEventText, sizeof(lastEventText), "A/C status requested");
          printNextStatusChange = false;
        }

        acAmpIndex = 0;
      }
    }
  }
}


bool acAmpPacketChanged() {
  if (!acAmpRxLastValid) {
    return true;
  }

  for (byte i = 0; i < 6; i++) {
    if (acAmpRxData[i] != acAmpRxDataLast[i]) {
      return true;
    }
  }

  return false;
}


void rememberAcPacket() {
  memcpy(acAmpRxDataLast, acAmpRxData, 6);
  acAmpRxLastValid = true;
}


// ======================================================
// A/C decode helpers
// ======================================================

VentMode getCurrentVentMode() {
  if (!acAmpRxPacketValid) {
    return VENT_UNKNOWN;
  }

  // Treat front demist as its own mode.
  if (getFrontDemistState()) {
    return VENT_FRONT_DEMIST;
  }

  bool bit0 = bitRead(acAmpRxData[4], 0);
  bool bit1 = bitRead(acAmpRxData[4], 1);

  if (bit0 && bit1) {
    return VENT_FEET;
  } else if (bit0 && !bit1) {
    return VENT_FEET_DEMIST;
  } else if (!bit0 && !bit1) {
    return VENT_FACE;
  } else if (!bit0 && bit1) {
    return VENT_FACE_FEET;
  }

  return VENT_UNKNOWN;
}


const char* ventModeName(VentMode mode) {
  switch (mode) {
    case VENT_FEET:
      return "feet";

    case VENT_FEET_DEMIST:
      return "feet + demist";

    case VENT_FACE:
      return "face";

    case VENT_FACE_FEET:
      return "face + feet";

    case VENT_FRONT_DEMIST:
      return "front demist";

    default:
      return "unknown";
  }
}


byte getFanSpeed() {
  if (!acAmpRxPacketValid) {
    return 0;
  }

  byte fanRaw = 0;

  bitWrite(fanRaw, 2, bitRead(acAmpRxData[2], 6));
  bitWrite(fanRaw, 1, bitRead(acAmpRxData[2], 5));
  bitWrite(fanRaw, 0, bitRead(acAmpRxData[2], 4));

  // raw 0..6 becomes fan 1..7
  // raw 7 becomes fan off / 0
  if (fanRaw <= 6) {
    return fanRaw + 1;
  }

  return 0;
}


byte getTempDigit1() {
  if (!acAmpRxPacketValid) return 0;
  return acAmpRxData[1] & 0x0F;
}


byte getTempDigit2() {
  if (!acAmpRxPacketValid) return 0;
  return acAmpRxData[2] & 0x0F;
}


byte getTempDigit3() {
  if (!acAmpRxPacketValid) return 0;
  return acAmpRxData[3] & 0x0F;
}


bool getAutoState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[3], 6);
}


bool getAcState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[3], 5);
}


bool getEcoState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[3], 4);
}


bool getFreshAirState() {
  if (!acAmpRxPacketValid) return false;
  return bitRead(acAmpRxData[4], 3);
}


bool getRecircState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[4], 3);
}


bool getFrontDemistState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[4], 6);
}


bool getRearDemistState() {
  if (!acAmpRxPacketValid) return false;
  return !bitRead(acAmpRxData[4], 5);
}


bool getAcAmpOnState() {
  if (!acAmpRxPacketValid) return false;
  return acAmpRxData[4] != 0xFF;
}


bool getAcAmpAmbientState() {
  if (!acAmpRxPacketValid) return false;
  return acAmpRxData[0] == 0x0E;
}


bool getAcAmpRunningState() {
  return getFanSpeed() > 0;
}


// ======================================================
// A/C send and mode target handling
// ======================================================

void acAmpSend() {
  for (byte i = 0; i < 5; i++) {
    Serial7.write(acAmpDataOut[i]);
  }

  acAmpTxBetweenTime = millis();
}


void requestVentMode(VentMode mode) {
  requestedVentMode = mode;
  modeStepCount = 0;
  lastModeStepTime = 0;

  snprintf(lastEventText, sizeof(lastEventText), "requested vent mode: %s", ventModeName(mode));
}


void handleRequestedVentMode() {
  if (requestedVentMode == VENT_UNKNOWN) {
    return;
  }

  if (!acAmpRxPacketValid) {
    setDefaultPacket();
    acAmpSend();
    return;
  }

  VentMode currentMode = getCurrentVentMode();

  if (currentMode == requestedVentMode) {
    snprintf(lastEventText, sizeof(lastEventText), "vent mode reached: %s", ventModeName(currentMode));

    requestedVentMode = VENT_UNKNOWN;
    modeStepCount = 0;

    setDefaultPacket();
    acAmpSend();
    return;
  }

  if (modeStepCount >= modeStepMax) {
    snprintf(lastEventText, sizeof(lastEventText), "mode target failed");

    requestedVentMode = VENT_UNKNOWN;
    modeStepCount = 0;

    setDefaultPacket();
    acAmpSend();
    return;
  }

  if (millis() - lastModeStepTime >= modeStepWaitTime) {
    if (currentMode == VENT_FRONT_DEMIST && requestedVentMode != VENT_FRONT_DEMIST) {
      setFrontDemistButtonPacket();
      snprintf(lastEventText, sizeof(lastEventText), "disabling front demist");
    } else if (requestedVentMode == VENT_FRONT_DEMIST) {
      setFrontDemistButtonPacket();
      snprintf(lastEventText, sizeof(lastEventText), "enabling front demist");
    } else {
      setModeButtonPacket();
      snprintf(lastEventText, sizeof(lastEventText), "mode step %u/%u", modeStepCount + 1, modeStepMax);
    }

    acAmpSend();

    modeStepCount++;
    lastModeStepTime = millis();
  } else {
    setDefaultPacket();
    acAmpSend();
  }
}


void checkAndSendHardwareControl() {
  if (millis() - acAmpTxBetweenTime >= acAmpTxWaitTime) {
    if (requestedVentMode != VENT_UNKNOWN) {
      handleRequestedVentMode();
      return;
    }

    if (sendCustomPacket) {
      acAmpSend();

      snprintf(lastEventText, sizeof(lastEventText), "sent command: %s", pendingCommand.c_str());

      sendCustomPacket = false;
      pendingCommand = "";
    } else {
      setDefaultPacket();
      acAmpSend();
    }
  }
}


// ======================================================
// USB serial command input
// ======================================================

void readSerialCommands() {
  while (Serial.available() > 0) {
    String cmd = Serial.readStringUntil('\n');
    cmd.trim();

    if (cmd.length() == 0) {
      return;
    }

    processAButtonCommand(cmd);
  }
}


void processAButtonCommand(String cmd) {
  cmd.trim();
  cmd.toLowerCase();

  setDefaultPacket();

  strncpy(lastCommandText, cmd.c_str(), sizeof(lastCommandText) - 1);
  lastCommandText[sizeof(lastCommandText) - 1] = '\0';
  lastCommandMs = millis();

  if (cmd == "feet") {
    requestVentMode(VENT_FEET);
    return;
  }

  else if (cmd == "feetdemist" || cmd == "feet/demist") {
    requestVentMode(VENT_FEET_DEMIST);
    return;
  }

  else if (cmd == "face") {
    requestVentMode(VENT_FACE);
    return;
  }

  else if (cmd == "facefeet" || cmd == "face/feet") {
    requestVentMode(VENT_FACE_FEET);
    return;
  }

  else if (cmd == "demist" || cmd == "frontdemistmode" || cmd == "windscreen") {
    requestVentMode(VENT_FRONT_DEMIST);
    return;
  }

  else if (cmd == "auto") {
    setCommandPacket(0x82, 0x80, 0x80);
  }

  else if (cmd == "mode") {
    setModeButtonPacket();
  }

  else if (cmd == "ac" || cmd == "a/c") {
    setCommandPacket(0x84, 0x80, 0x80);
  }

  else if (cmd == "frontdemist" || cmd == "front" || cmd == "defrost") {
    setFrontDemistButtonPacket();
    printNextStatusChange = true;
  }

  else if (cmd == "reardemist" || cmd == "rear") {
    setCommandPacket(0xC0, 0x80, 0x80);
  }

  else if (cmd == "airsource" || cmd == "recirc" || cmd == "fresh") {
    setCommandPacket(0x88, 0x80, 0x80);
  }

  else if (cmd == "off") {
    setCommandPacket(0x81, 0x80, 0x80);
  }

  else if (cmd == "fanup" || cmd == "fan+") {
    setCommandPacket(0x80, 0x80, 0x90);
  }

  else if (cmd == "fandown" || cmd == "fan-") {
    byte currentFanSpeed = getFanSpeed();

    if (acAmpRxPacketValid && currentFanSpeed == 1) {
      // Fan 1 -> off
      setCommandPacket(0x81, 0x80, 0x80);
      snprintf(lastEventText, sizeof(lastEventText), "fan 1 -> sending OFF");
    } else {
      setCommandPacket(0x80, 0x80, 0xF0);
    }
  }

  else if (cmd == "tempup" || cmd == "temp+") {
    setCommandPacket(0x80, 0x80, 0x81);
  }

  else if (cmd == "tempdown" || cmd == "temp-") {
    setCommandPacket(0x80, 0x80, 0x87);
  }

  else if (cmd == "ambient" || cmd == "amb") {
    setCommandPacket(0x80, 0xA0, 0x80);
  }

  else if (cmd == "status") {
    printCurrentStatusText();
    return;
  }

  else if (cmd == "help" || cmd == "?") {
    printHelp();
    return;
  }

  else if (cmd == "idle" || cmd == "default") {
    setDefaultPacket();
  }

  else {
    snprintf(lastEventText, sizeof(lastEventText), "unknown command: %s", cmd.c_str());
#if ENABLE_PI_LINK_STREAM
    // ERR,unknown_command,1 means Pi sent a command this sketch did not recognise.
    // The rejected command string is intentionally not echoed on the Pi link.
    PI_LINK_SERIAL.println("ERR,unknown_command,1");
#endif
    return;
  }

  sendCustomPacket = true;
  pendingCommand = cmd;

  snprintf(lastEventText, sizeof(lastEventText), "queued command: %s", cmd.c_str());
}


// ======================================================
// CAN byte helpers
// ======================================================

static uint16_t u16be(const CAN_message_t &m, uint8_t i) {
  return ((uint16_t)m.buf[i] << 8) | m.buf[i + 1];
}


static int16_t s16be(const CAN_message_t &m, uint8_t i) {
  return (int16_t)u16be(m, i);
}


static uint16_t u16bePayload(const uint8_t *p) {
  return ((uint16_t)p[0] << 8) | p[1];
}


static float decodeSignedTrim(uint8_t v) {
  return ((float)v - 128.0f) * 100.0f / 128.0f;
}


// ======================================================
// Passive RX-8 CAN decode
// ======================================================

static void processPassiveFrame(const CAN_message_t &m) {
  if (m.flags.extended) return;

  switch (m.id) {
    case 0x081: {
      if (m.len < 4) return;

      float steeringWheelAngle = (float)s16be(m, 2);
      float roadAngle = steeringWheelAngle / STEERING_RATIO;

      updateValueFloat("steering_wheel_deg", steeringWheelAngle, 0);
      updateValueFloat("road_wheel_est_deg", roadAngle, 2);
      return;
    }

    case 0x201: {
      if (m.len < 8) return;

      float rpm      = u16be(m, 0) / 3.85f;
      float speed    = ((int32_t)u16be(m, 4) - 10000L) / 100.0f;
      float throttle = m.buf[6] / 2.0f;

      updateValueFloat("rpm", rpm, 0);
      updateValueFloat("speed_kmh", speed, 2);
      updateValueFloat("throttle_pedal_percent", throttle, 1);
      return;
    }

    case 0x4B0: {
      if (m.len < 8) return;

      updateValueFloat("wheel_fl_kmh", ((int32_t)u16be(m, 0) - 10000L) / 100.0f, 2);
      updateValueFloat("wheel_fr_kmh", ((int32_t)u16be(m, 2) - 10000L) / 100.0f, 2);
      updateValueFloat("wheel_rl_kmh", ((int32_t)u16be(m, 4) - 10000L) / 100.0f, 2);
      updateValueFloat("wheel_rr_kmh", ((int32_t)u16be(m, 6) - 10000L) / 100.0f, 2);
      return;
    }

    case 0x4B1: {
      if (m.len < 8) return;

      updateValueFloat("direct_wheel_fl_kmh", u16be(m, 0) / 100.0f, 2);
      updateValueFloat("direct_wheel_fr_kmh", u16be(m, 2) / 100.0f, 2);
      updateValueFloat("direct_wheel_rl_kmh", u16be(m, 4) / 100.0f, 2);
      updateValueFloat("direct_wheel_rr_kmh", u16be(m, 6) / 100.0f, 2);
      return;
    }
  }
}


static void drainCanRx() {
  CAN_message_t rx;

  while (Can3.read(rx)) {
    processPassiveFrame(rx);
  }
}


// ======================================================
// ISO-TP / diagnostic request handling
// ======================================================

static void sendFlowControl(uint32_t responseId) {
  CAN_message_t fc;

  fc.id = (responseId >= 0x7E8 && responseId <= 0x7EF)
            ? responseId - 8
            : OBD_PHYSICAL_REQUEST_ID;

  fc.len = 8;
  fc.flags.extended = 0;
  fc.buf[0] = 0x30;
  memset(&fc.buf[1], 0, 7);

  Can3.write(fc);
}


static void sendOBD01(uint8_t pid) {
  CAN_message_t req;

#if USE_PHYSICAL_OBD_ID
  req.id = OBD_PHYSICAL_REQUEST_ID;
#else
  req.id = OBD_FUNCTIONAL_REQUEST_ID;
#endif

  req.len = 8;
  req.flags.extended = 0;

  req.buf[0] = 0x02;
  req.buf[1] = 0x01;
  req.buf[2] = pid;

  memset(&req.buf[3], 0, 5);

  Can3.write(req);
}


static void sendUDS22(uint16_t did) {
  CAN_message_t req;

  req.id = OBD_PHYSICAL_REQUEST_ID;
  req.len = 8;
  req.flags.extended = 0;

  req.buf[0] = 0x03;
  req.buf[1] = 0x22;
  req.buf[2] = highByte(did);
  req.buf[3] = lowByte(did);

  memset(&req.buf[4], 0, 4);

  Can3.write(req);
}


static bool readIsoTpPayload(RequestType type, uint16_t id, uint8_t *payload, int &payloadLen, int &nrc) {
  payloadLen = 0;
  nrc = 0;

  uint8_t fullData[96];
  int fullLen = 0;
  int expectedLen = -1;

  const uint8_t positiveService = (type == REQ_OBD01) ? 0x41 : 0x62;
  const uint8_t requestService  = (type == REQ_OBD01) ? 0x01 : 0x22;

  uint32_t start = micros();

  while ((uint32_t)(micros() - start) < RESPONSE_TIMEOUT_US) {
    if (!Can3.read(msg)) continue;

    if (msg.id < DIAG_RESPONSE_MIN_ID || msg.id > DIAG_RESPONSE_MAX_ID) {
      processPassiveFrame(msg);
      continue;
    }

    uint8_t pci = msg.buf[0];
    uint8_t frameType = pci & 0xF0;

    // Negative response
    if (frameType == 0x00 && msg.buf[1] == 0x7F && msg.buf[2] == requestService) {
      nrc = msg.buf[3];
      return false;
    }

    // Single frame
    if (frameType == 0x00) {
      int len = pci & 0x0F;
      if (len <= 0 || len > 7) return false;

      if (type == REQ_OBD01) {
        if (len < 2 || msg.buf[1] != positiveService || msg.buf[2] != (uint8_t)id) continue;

        payloadLen = len - 2;
        memcpy(payload, &msg.buf[3], payloadLen);
        return true;
      } else {
        if (len < 3 || msg.buf[1] != positiveService || msg.buf[2] != highByte(id) || msg.buf[3] != lowByte(id)) continue;

        payloadLen = len - 3;
        memcpy(payload, &msg.buf[4], payloadLen);
        return true;
      }
    }

    // First frame
    if (frameType == 0x10) {
      expectedLen = ((pci & 0x0F) << 8) | msg.buf[1];
      if (expectedLen <= 0 || expectedLen > 96) return false;

      int n = expectedLen < 6 ? expectedLen : 6;
      memcpy(fullData, &msg.buf[2], n);
      fullLen = n;

      sendFlowControl(msg.id);

      uint32_t mfStart = micros();

      while ((uint32_t)(micros() - mfStart) < RESPONSE_TIMEOUT_US && fullLen < expectedLen) {
        if (!Can3.read(msg)) continue;

        if (msg.id < DIAG_RESPONSE_MIN_ID || msg.id > DIAG_RESPONSE_MAX_ID) {
          processPassiveFrame(msg);
          continue;
        }

        if ((msg.buf[0] & 0xF0) != 0x20) continue;

        int rem = expectedLen - fullLen;
        if (rem > 7) rem = 7;

        memcpy(&fullData[fullLen], &msg.buf[1], rem);
        fullLen += rem;
      }

      if (fullLen < expectedLen) return false;

      if (type == REQ_OBD01) {
        if (expectedLen < 2 || fullData[0] != positiveService || fullData[1] != (uint8_t)id) return false;

        payloadLen = expectedLen - 2;
        if (payloadLen > 80) payloadLen = 80;

        memcpy(payload, &fullData[2], payloadLen);
        return true;
      } else {
        if (expectedLen < 3 || fullData[0] != positiveService || fullData[1] != highByte(id) || fullData[2] != lowByte(id)) return false;

        payloadLen = expectedLen - 3;
        if (payloadLen > 80) payloadLen = 80;

        memcpy(payload, &fullData[3], payloadLen);
        return true;
      }
    }
  }

  return false;
}


// ======================================================
// Text / status decoders
// ======================================================

static bool looksAscii(const uint8_t *p, int len) {
  if (len <= 0) return false;

  int cnt = 0;

  for (int i = 0; i < len; i++) {
    if (p[i] == 0) continue;
    if (p[i] < 0x20 || p[i] > 0x7E) return false;
    cnt++;
  }

  return cnt > 0;
}


static void outputAsciiValue(const char *key, const uint8_t *p, int len) {
  char tmp[28];
  int j = 0;

  for (int i = 0; i < len && j < (int)sizeof(tmp) - 1; i++) {
    if (p[i] >= 0x20 && p[i] <= 0x7E) {
      tmp[j++] = (char)p[i];
    }
  }

  tmp[j] = '\0';
  updateValueText(key, tmp);
}


// Numeric status mappings
// ======================================================

// fuel_system_status mapping uses the raw OBD Mode 01 PID 03 bit value:
//   0  = unused / unavailable
//   1  = open loop, insufficient engine temperature
//   2  = closed loop, using oxygen sensor feedback
//   4  = open loop due to load or fuel cut
//   8  = open loop due to system failure
//   16 = closed loop but oxygen sensor fault present
static void outputFuelSystemStatus(const PIDDef &d, const uint8_t *p, int len) {
  if (len < 1) return;
  updateValueFloat(d.key, p[0], 0);
}


static void outputRearO2(const PIDDef &d, const uint8_t *p, int len) {
  if (len < 1) return;

  // Old text value was "voltage + trim". Numeric-only stream sends them separately:
  //   rear_o2_v            = rear O2 voltage in volts
  //   rear_o2_trim_percent = signed fuel trim percentage when available
  updateValueFloat("rear_o2_v", p[0] / 200.0f, 3);

  if (len >= 2) {
    updateValueFloat("rear_o2_trim_percent", decodeSignedTrim(p[1]), 1);
  }
}


static void outputWidebandO2Pid34(const PIDDef &d, const uint8_t *p, int len) {
  if (len < 4) return;

  float lambda = u16bePayload(&p[0]) / 32768.0f;
  float afr = lambda * PETROL_STOICH_AFR;
  float mA = (u16bePayload(&p[2]) / 256.0f) - 128.0f;

  // Numeric-only split of the old front_wideband_lambda_ma text value.
  updateValueFloat("front_wideband_lambda", lambda, 3);
  updateValueFloat("front_wideband_current_ma", mA, 3);

  updateValueFloat("actual_lambda", lambda, 3);
  updateValueFloat("actual_afr", afr, 2);
}


static void outputA211State(const PIDDef &d, const uint8_t *p, int len) {
  if (len < 2) return;

  uint8_t b0 = p[0];
  uint8_t b1 = p[1];

  // gear_clutch_state mapping:
  //   0   = neutral, clutch out
  //   1   = neutral, clutch in
  //   2   = in gear, clutch out
  //   3   = in gear, clutch in
  //   255 = unknown/raw combination
  uint8_t code = 255;
  uint8_t neutral = 255;
  uint8_t clutchIn = 255;

  if (b0 == 0x04 && b1 == 0x00) {
    code = 0;
    neutral = 1;
    clutchIn = 0;
  } else if (b0 == 0x04 && b1 == 0x01) {
    code = 1;
    neutral = 1;
    clutchIn = 1;
  } else if (b0 == 0x00 && b1 == 0x00) {
    code = 2;
    neutral = 0;
    clutchIn = 0;
  } else if (b0 == 0x00 && b1 == 0x01) {
    code = 3;
    neutral = 0;
    clutchIn = 1;
  }

  updateValueFloat(d.key, code, 0);
  updateValueFloat("gear_neutral", neutral, 0);       // 0 no, 1 yes, 255 unknown
  updateValueFloat("clutch_pressed", clutchIn, 0);    // 0 no, 1 yes, 255 unknown
  updateValueFloat("gear_clutch_raw_b0", b0, 0);
  updateValueFloat("gear_clutch_raw_b1", b1, 0);
}


static bool outputOBDStatus(const PIDDef &d, const uint8_t *p, int len) {
  switch (d.id) {
    case 0x0003:
      outputFuelSystemStatus(d, p, len);
      return true;

    case 0x0015:
      outputRearO2(d, p, len);
      return true;

    case 0x0034:
      outputWidebandO2Pid34(d, p, len);
      return true;
  }

  return false;
}


static bool outputDIDStatus(const PIDDef &d, const uint8_t *p, int len) {
  if (len < 1) return true;

  switch (d.id) {
    case 0xA211:
      outputA211State(d, p, len);
      return true;

    case 0x1631:
      // o2_heater_status: raw bitfield value from DID 0x1631.
      //   0 = heaters off, non-zero = raw heater bitfield.
      updateValueFloat(d.key, p[0], 0);
      return true;

    case 0x1706:
    case 0x1104:
    case 0x1718:
    case 0x1711:
    case 0x1688:
    case 0x1715:
      // Generic ON/OFF mapping for these DIDs:
      //   0 = off / inactive
      //   1 = on / active
      updateValueFloat(d.key, p[0] ? 1 : 0, 0);
      return true;

    case 0x0968: {
      // generator_engine_flag: combined raw bytes.
      //   if two bytes exist: value = b0*256 + b1
      //   if one byte exists:  value = b0
      uint16_t raw = len >= 2 ? (((uint16_t)p[0] << 8) | p[1]) : p[0];
      updateValueFloat(d.key, raw, 0);
      return true;
    }

    case 0x09D3: {
      // vfad_status: combined raw bytes.
      //   if two bytes exist: value = b0*256 + b1
      //   if one byte exists:  value = b0
      uint16_t raw = len >= 2 ? (((uint16_t)p[0] << 8) | p[1]) : p[0];
      updateValueFloat(d.key, raw, 0);
      return true;
    }

    case 0x1103:
      // apv_position_status: raw numeric status byte.
      updateValueFloat(d.key, p[0], 0);
      return true;
  }

  return false;
}


// ======================================================
// Numeric decoders
// ======================================================

static float decodeOBD01(uint16_t pid, const uint8_t *p, int len, bool &ok) {
  ok = true;

  uint16_t ab = len >= 2 ? u16bePayload(p) : 0;

  switch (pid) {
    case 0x0005:
    case 0x000F:
      if (len >= 1) return p[0] - 40.0f;
      break;

    case 0x0010:
      if (len >= 2) return ab / 100.0f;
      break;

    case 0x0042:
      if (len >= 2) return ab / 1000.0f;
      break;

    case 0x0045:
    case 0x002F:
    case 0x0049:
    case 0x004A:
    case 0x0011:
    case 0x004C:
    case 0x0047:
    case 0x002E:
      if (len >= 1) return p[0] * 100.0f / 255.0f;
      break;

    case 0x0006:
    case 0x0007:
      if (len >= 1) return decodeSignedTrim(p[0]);
      break;

    case 0x000E:
      if (len >= 1) return (p[0] / 2.0f) - 64.0f;
      break;

    case 0x003C:
      if (len >= 2) return (ab / 10.0f) - 40.0f;
      break;

    case 0x0033:
      if (len >= 1) return (float)p[0];
      break;

    case 0x0044:
      if (len >= 2) return ab / 32768.0f;
      break;
  }

  ok = false;
  return 0.0f;
}


static float decodeUDS22(uint16_t did, const uint8_t *p, int len, bool &ok) {
  ok = true;

  uint16_t ab = len >= 2 ? u16bePayload(p) : 0;

  switch (did) {
    case 0x1746:
      if (len >= 1) return p[0] / 2.0f;
      break;

    case 0x1410:
      if (len >= 2) return ab / 1000.0f;
      break;

    case 0x0904:
      if (len >= 1) return (p[0] / 2.0f) - 64.0f;
      break;

    case 0x0914:
    case 0x0915:
    case 0x0917:
    case 0x0918:
      if (len >= 2) return ab / 1000.0f;
      if (len >= 1) return p[0] * 5.0f / 255.0f;
      break;

    case 0x091A:
    case 0x093C:
      if (len >= 2) return ab / 256.0f;
      break;

    case 0x114D:
      if (len >= 2) return ab / 1000.0f;
      break;

    case 0x1154:
      if (len >= 2) return ab * 100.0f / 65535.0f;
      if (len >= 1) return p[0] * 100.0f / 255.0f;
      break;

    case 0x1634:
      if (len >= 1) return p[0] * 5.0f / 255.0f;
      break;

    case 0x16E8:
      if (len >= 2) return ab / 1000.0f;
      break;

    case 0x172D:
      if (len >= 1) return p[0] * 100.0f / 255.0f;
      break;
  }

  ok = false;
  return 0.0f;
}


static int decimalsForValue(const PIDDef &d) {
  if (d.type == REQ_UDS22) {
    switch (d.id) {
      case 0x0914:
      case 0x0915:
      case 0x0917:
      case 0x0918:
      case 0x114D:
      case 0x1634:
      case 0x16E8:
      case 0x1410:
        return 3;

      case 0x0904:
      case 0x1746:
        return 1;
    }
  }

  if (d.type == REQ_OBD01) {
    switch (d.id) {
      case 0x0005:
      case 0x000F:
      case 0x0033:
        return 0;

      case 0x0010:
      case 0x0042:
      case 0x0044:
        return 3;

      case 0x000E:
        return 1;
    }
  }

  return 2;
}


// Return:
//   1  = valid response
//   0  = negative response
//  -1  = timeout
static int pollOne(const PIDDef &d) {
  uint8_t payload[96];
  int payloadLen = 0;
  int nrc = 0;

  drainCanRx();

  if (d.type == REQ_OBD01) {
    sendOBD01((uint8_t)d.id);
  } else {
    sendUDS22(d.id);
  }

  bool ok = readIsoTpPayload(d.type, d.id, payload, payloadLen, nrc);

  if (!ok) {
    return nrc > 0 ? 0 : -1;
  }

  bool handled = d.type == REQ_OBD01
                   ? outputOBDStatus(d, payload, payloadLen)
                   : outputDIDStatus(d, payload, payloadLen);

  if (handled) {
    return 1;
  }

  bool decoded = false;

  float val = d.type == REQ_OBD01
                ? decodeOBD01(d.id, payload, payloadLen, decoded)
                : decodeUDS22(d.id, payload, payloadLen, decoded);

  if (decoded) {
    updateValueFloat(d.key, val, decimalsForValue(d));

    if (d.type == REQ_OBD01 && d.id == 0x0044) {
      updateValueFloat("commanded_lambda", val, 3);
      updateValueFloat("commanded_afr", val * PETROL_STOICH_AFR, 2);
    }

  } else if (looksAscii(payload, payloadLen)) {
    // ASCII diagnostic data cannot be sent as a text value on the Pi stream.
    // Store it only for USB debug, and send numeric byte values for the Pi.
    outputAsciiValue(d.key, payload, payloadLen);
    updateValueFloat(d.key, payloadLen, 0);
  }

  return 1;
}


// ======================================================
// Raspberry Pi UART protocol
// ======================================================

void piBegin() {
#if ENABLE_PI_LINK_STREAM
  // Numeric-only startup info.
  // INFO,ready,1       -> Teensy link is alive
  // INFO,baud,1000000  -> Pi UART baud rate
  // INFO,protocol,1    -> protocol version 1: V,key,numeric_value
  PI_LINK_SERIAL.println("INFO,ready,1");
  PI_LINK_SERIAL.println("INFO,baud,1000000");
  PI_LINK_SERIAL.println("INFO,protocol,1");
#endif
}


void piSendValueText(const char *key, const char *value) {
#if ENABLE_PI_LINK_STREAM
  PI_LINK_SERIAL.print("V,");
  PI_LINK_SERIAL.print(key);
  PI_LINK_SERIAL.print(",");
  PI_LINK_SERIAL.println(value);
#endif
}


void piSendValueFloat(const char *key, float value, int decimals) {
#if ENABLE_PI_LINK_STREAM
  char tmp[28];
  snprintf(tmp, sizeof(tmp), "%.*f", decimals, (double)value);
  piSendValueText(key, tmp);
#endif
}


void piSendValueInt(const char *key, int32_t value) {
#if ENABLE_PI_LINK_STREAM
  PI_LINK_SERIAL.print("V,");
  PI_LINK_SERIAL.print(key);
  PI_LINK_SERIAL.print(",");
  PI_LINK_SERIAL.println(value);
#endif
}


void piReadCommands() {
  while (PI_LINK_SERIAL.available() > 0) {
    String line = PI_LINK_SERIAL.readStringUntil('\n');
    line.trim();

    if (line.length() == 0) {
      return;
    }

    processIncomingCommandLine(line);
  }
}


void processIncomingCommandLine(String line) {
  line.trim();

  // Pi can send:
  //   C,fanup
  //   C,tempdown
  //   C,face
  //
  // Or plain:
  //   fanup

  if (line.startsWith("C,")) {
    line.remove(0, 2);
    line.trim();
  }

  if (line.length() == 0) {
    return;
  }

  processAButtonCommand(line);

#if ENABLE_PI_LINK_STREAM
  // ACK,1 means the command line was accepted and queued/handled.
  PI_LINK_SERIAL.println("ACK,1");
#endif
}


void piSendAcStatus() {
#if ENABLE_PI_LINK_STREAM
  if (!acAmpRxPacketValid) {
    piSendValueInt("ac_rx_valid", 0);
    return;
  }

  piSendValueInt("ac_rx_valid", 1);

  float acTemp = (float)(getTempDigit1() * 10 + getTempDigit2()) + ((float)getTempDigit3() / 10.0f);

  // ac_mode mapping comes from VentMode enum:
  //   0 unknown, 1 feet, 2 feet+demist, 3 face, 4 face+feet, 5 front demist
  piSendValueFloat("ac_temp", acTemp, 1);
  piSendValueInt("ac_fan", getFanSpeed());              // 0 = off, 1..7 = fan speed
  piSendValueInt("ac_mode", (int)getCurrentVentMode());

  piSendValueInt("ac_amp_on", getAcAmpOnState() ? 1 : 0);
  piSendValueInt("ac_running", getAcAmpRunningState() ? 1 : 0);
  piSendValueInt("ac_auto", getAutoState() ? 1 : 0);
  piSendValueInt("ac_compressor", getAcState() ? 1 : 0);
  piSendValueInt("ac_eco", getEcoState() ? 1 : 0);
  piSendValueInt("ac_amp_ambient", getAcAmpAmbientState() ? 1 : 0);

  // ac_air_source mapping:
  //   0 = recirc
  //   1 = fresh
  piSendValueInt("ac_air_source", getFreshAirState() ? 1 : 0);

  piSendValueInt("ac_front_demist", getFrontDemistState() ? 1 : 0);
  piSendValueInt("ac_rear_demist", getRearDemistState() ? 1 : 0);

  // Raw A/C bytes as decimal 0..255. This replaces the old text hex string.
  piSendValueInt("ac_raw_0", acAmpRxData[0]);
  piSendValueInt("ac_raw_1", acAmpRxData[1]);
  piSendValueInt("ac_raw_2", acAmpRxData[2]);
  piSendValueInt("ac_raw_3", acAmpRxData[3]);
  piSendValueInt("ac_raw_4", acAmpRxData[4]);
  piSendValueInt("ac_raw_5", acAmpRxData[5]);
#endif
}


void updateFuelEconomy() {
  if (!haveMafGps) {
    return;
  }

  float afrForFuel = PETROL_STOICH_AFR;

  // Best: actual wideband AFR.
  // Fallback: commanded AFR.
  // Final fallback: stoich 14.7.
  if (haveActualAfr && latestActualAfr > 8.0f && latestActualAfr < 25.0f) {
    afrForFuel = latestActualAfr;
  } else if (haveCommandedAfr && latestCommandedAfr > 8.0f && latestCommandedAfr < 25.0f) {
    afrForFuel = latestCommandedAfr;
  }

  float fuelGps = latestMafGps / afrForFuel;
  float fuelLps = fuelGps / PETROL_DENSITY_G_PER_L;
  float fuelLph = fuelLps * 3600.0f;

  updateValueFloat("fuel_lph", fuelLph, 2);
  updateValueFloat("fuel_afr_used", afrForFuel, 2);

  if (haveSpeedKmh && latestSpeedKmh >= MIN_L100_SPEED_KMH) {
    float instL100 = (fuelLph * 100.0f) / latestSpeedKmh;
    updateValueFloat("inst_l_100km", instL100, 2);
    // inst_fuel_mode mapping: 0 = L/100km, 1 = L/h
    updateValueFloat("inst_fuel_mode", 0, 0);
  } else {
    updateValueFloat("inst_l_h", fuelLph, 2);
    // inst_fuel_mode mapping: 0 = L/100km, 1 = L/h
    updateValueFloat("inst_fuel_mode", 1, 0);
  }
}


// ======================================================
// Help / status printing
// ======================================================

void printCurrentStatusText() {
#if USE_ANSI_DASHBOARD
  Serial.print("\033[2J\033[H");
#endif

  Serial.println("Current A/C status:");

  if (!acAmpRxPacketValid) {
    Serial.println("No valid A/C RX packet yet.");
    delay(1800);
    return;
  }

  Serial.print("Raw RX: ");
  printAcRaw();
  Serial.println();

  Serial.print("Fan: ");
  Serial.println(getFanSpeed());

  Serial.print("Mode: ");
  Serial.println(ventModeName(getCurrentVentMode()));

  Serial.print("Auto: ");
  Serial.println(getAutoState() ? "auto" : "manual");

  Serial.print("A/C: ");
  Serial.println(getAcState() ? "on" : "off");

  Serial.print("Air source: ");
  Serial.println(getFreshAirState() ? "fresh" : "recirc");

  Serial.print("Front demist: ");
  Serial.println(getFrontDemistState() ? "on" : "off");

  Serial.print("Rear demist: ");
  Serial.println(getRearDemistState() ? "on" : "off");

  Serial.println();
  Serial.println("Dashboard will resume.");
  delay(2500);
}


void printHelp() {
#if USE_ANSI_DASHBOARD
  Serial.print("\033[2J\033[H");
#endif

  Serial.println("Available USB/Pi commands:");
  Serial.println();
  Serial.println("  auto              -> Auto button");
  Serial.println("  mode              -> Single physical Mode button press");
  Serial.println();
  Serial.println("  feet              -> Target feet mode");
  Serial.println("  feetdemist        -> Target feet + demist mode");
  Serial.println("  face              -> Target face mode");
  Serial.println("  facefeet          -> Target face + feet mode");
  Serial.println("  demist            -> Target front demist/windscreen mode");
  Serial.println();
  Serial.println("  ac                -> A/C button");
  Serial.println("  frontdemist       -> Raw front demist button");
  Serial.println("  reardemist        -> Rear demist button");
  Serial.println("  airsource         -> Fresh/recirc button");
  Serial.println("  off               -> Off button");
  Serial.println();
  Serial.println("  fanup             -> Fan speed up");
  Serial.println("  fandown           -> Fan speed down");
  Serial.println("  tempup            -> Temperature up");
  Serial.println("  tempdown          -> Temperature down");
  Serial.println();
  Serial.println("  ambient           -> Ambient display command");
  Serial.println("  status            -> Print current decoded A/C status");
  Serial.println("  idle              -> Send idle packet once");
  Serial.println("  help              -> Show this list");
  Serial.println();
  Serial.println("Pi command format:");
  Serial.println("  C,fanup");
  Serial.println("  C,tempdown");
  Serial.println("  C,face");
  Serial.println();
  Serial.println("Pi receives:");
  Serial.println("  V,key,value");
  Serial.println();
  Serial.println("Dashboard will resume.");
  delay(3500);
}