/**
 * weFind Ball — BLE Advertise Prototype
 *
 * Target: Seeed Studio XIAO BLE Sense (nRF52840)
 * Library: bluefruit.h — built into the Seeed nRF52 board package, no install needed
 *
 * What this does:
 *   - Advertises a custom BLE service UUID so an iPhone can detect the ball
 *   - Blinks the onboard LED once per second to confirm it's running
 *
 * Setup:
 *   1. Select board: Seeed nRF52 Boards > Seeed XIAO BLE Sense - nRF52840
 *   2. Upload this sketch
 *   3. Open nRF Connect app on iPhone, scan — you should see "weFind Ball"
 */

#include <bluefruit.h>

// Custom service UUID for the weFind ball.
// This is what the iOS app will scan for.
// 128-bit UUID — keep this consistent across firmware and iOS app
const uint8_t WEFIND_SERVICE_UUID[] = {
  0x90, 0x78, 0x56, 0x34, 0x12, 0xEF, 0xCD, 0xAB,
  0x90, 0x78, 0xF6, 0xE5, 0xD4, 0xC3, 0xB2, 0xA1
};

BLEService ballService(WEFIND_SERVICE_UUID);

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  Bluefruit.begin();
  Bluefruit.setName("weFind Ball");

  ballService.begin();

  // Configure and start advertising
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();
  Bluefruit.Advertising.addService(ballService);
  Bluefruit.ScanResponse.addName();

  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(160, 160); // 100ms interval (units of 0.625ms)
  Bluefruit.Advertising.start(0);              // 0 = advertise forever
}

void loop() {
  // Slow blink = advertising OK
  digitalWrite(LED_BUILTIN, HIGH); delay(100);
  digitalWrite(LED_BUILTIN, LOW);  delay(900);
}
