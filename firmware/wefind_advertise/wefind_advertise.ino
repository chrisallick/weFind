/**
 * weFind Ball — BLE Advertise Prototype
 *
 * Target: Seeed Studio XIAO BLE Sense (nRF52840)
 * Library: ArduinoBLE (install via Arduino Library Manager)
 *
 * What this does:
 *   - Advertises a custom BLE service UUID so an iPhone can detect the ball
 *   - Blinks the onboard red LED once per second to confirm it's running
 *   - That's it — this is the simplest possible "phone finds ball" prototype
 *
 * Setup:
 *   1. Install ArduinoBLE via Arduino IDE > Tools > Manage Libraries
 *   2. Select board: Seeed nRF52 Boards > Seeed XIAO BLE Sense - nRF52840
 *   3. Upload this sketch
 *   4. Open nRF Connect app on iPhone, scan — you should see "weFind Ball"
 */

#include <ArduinoBLE.h>

// Custom service UUID for the weFind ball.
// This is what the iOS app will scan for.
// Generate your own at: https://www.uuidgenerator.net/
#define WEFIND_SERVICE_UUID "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"

BLEService ballService(WEFIND_SERVICE_UUID);

// Onboard LEDs on XIAO BLE Sense (active LOW)
#define LED_RED   LEDR
#define LED_GREEN LEDG
#define LED_BLUE  LEDB

void setup() {
  Serial.begin(115200);

  // LEDs are active LOW on XIAO BLE Sense
  pinMode(LED_RED,   OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_BLUE,  OUTPUT);
  digitalWrite(LED_RED,   HIGH);
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_BLUE,  HIGH);

  if (!BLE.begin()) {
    Serial.println("BLE init failed — check board selection");
    // Flash red rapidly to signal failure
    while (1) {
      digitalWrite(LED_RED, LOW);  delay(100);
      digitalWrite(LED_RED, HIGH); delay(100);
    }
  }

  BLE.setLocalName("weFind Ball");
  BLE.setAdvertisedService(ballService);
  BLE.addService(ballService);
  BLE.advertise();

  Serial.println("weFind Ball advertising — open nRF Connect on iPhone to verify");
  Serial.print("Service UUID: ");
  Serial.println(WEFIND_SERVICE_UUID);
}

void loop() {
  BLE.poll();

  // Slow green blink = advertising OK
  digitalWrite(LED_GREEN, LOW);  delay(100);
  digitalWrite(LED_GREEN, HIGH); delay(900);
}
