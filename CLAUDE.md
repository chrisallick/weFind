# weFind — Claude Context

A hardware + software product that embeds a BLE chip inside a dog ball, paired
with a native iOS app for proximity-based finding via Bluetooth Low Energy.

---

## Vision

Throw the ball. Lose it in tall grass. Open the app. Find it instantly.

No collar. No subscription. No MFi approval. Works with any iPhone.

---

## Current State (as of March 2026)

**Prototype is working end-to-end:**
- Firmware running on Seeed XIAO BLE Sense, advertising over BLE
- iOS app detecting the ball and displaying a proximity ring with haptics
- Next step: RSSI calibration outdoors, then put it in an actual ball

---

## Architecture Decisions (Resolved)

**BLE-only. No MFi. No Find My Network.**
- RSSI-based proximity is sufficient for the fetch use case
- Skipping MFi means no approval process or NDAs
- Trade-off: no precision UWB directional arrow (requires MFi + Qorvo DW3000 chip)
- v2 path exists if UWB ever pursued: nRF52840 + DW3000 + MFi enrollment

**Hardware: Seeed XIAO BLE Sense (nRF52840)**
- Chosen over nRF52840 DK — smaller, cheaper, same chip, works immediately
- Has onboard LSM6DS3TR-C IMU (motion gating prototype)
- Production target: custom PCB with nRF52832 + ADXL362 + CR2032

**Battery: LiPo for prototype, CR2032 for production**
- LiPo via JST connector now — easy to recharge during dev
- CR2032 target: wire to 3V3 pin (bypass BQ25101 charger), 2-3 year life

**Firmware: Arduino + bluefruit.h**
- Uses Seeed nRF52 board package (Adafruit nRF52 core)
- BLE library: `bluefruit.h` (built into board package — NOT ArduinoBLE)
- LED pins: `LED_RED`, `LED_GREEN`, `LED_BLUE` (active LOW)
- Bluetooth permission key in iOS: "Privacy - Bluetooth Always Usage Description"

---

## Repo Structure

```
firmware/
  wefind_advertise/
    wefind_advertise.ino    — BLE advertising sketch
  README.md

ios/
  weFind/
    weFindApp.swift         — App entry point
    ContentView.swift       — Proximity ring UI + haptics
    BLEManager.swift        — Core Bluetooth scanning + RSSI smoothing
  README.md

CLAUDE.md                   — This file
README.md                   — Project overview
TODO.md                     — Task list
```

---

## Key UUIDs

```
Service UUID: A1B2C3D4-E5F6-7890-ABCD-EF1234567890
```
Must match exactly between firmware and iOS app.

---

## Tech Stack

| Layer | Technology |
|---|---|
| BLE Chip | Seeed XIAO BLE Sense — Nordic nRF52840 |
| IMU | LSM6DS3TR-C (onboard, prototype) → ADXL362 (production) |
| Firmware | Arduino IDE + Seeed nRF52 board package + bluefruit.h |
| Battery | LiPo JST (prototype) → CR2032 (production) |
| iOS App | Swift + SwiftUI + Core Bluetooth (CBCentralManager) |
| Proximity | RSSI exponential moving average, no connection needed |
| Backend | None — fully local |

---

## Proximity Thresholds (needs outdoor calibration)

Defined in `BLEManager.swift → proximityFromRSSI()`.
Current values are guesses — calibrate by standing at known distances
and reading the RSSI value shown on screen.

Real-world use case distances:
- Ball detected: 100–200 ft
- Walking toward it: 40–80 ft
- Almost there: 15–40 ft
- Standing over it: 4–8 ft (phone in hand)

---

## Known Issues / Gotchas

- ArduinoBLE does NOT work with Seeed nRF52 board package — use `bluefruit.h`
- iOS Bluetooth permission key must be "Privacy - Bluetooth Always Usage Description"
  (not the raw plist key NSBluetoothAlwaysUsageDescription)
- Delete app and reinstall after adding Bluetooth permission for prompt to appear
- XIAO BLE Sense LEDs are active LOW (HIGH = off, LOW = on)
- Board must be double-tapped to enter DFU mode for upload on some machines

---

## Phase Roadmap

| Phase | Description | Status |
|---|---|---|
| 0 | Toolchain + hardware setup | Done |
| 1 | BLE advertising firmware | Done |
| 2 | iOS proximity app | Done (needs RSSI calibration) |
| 3 | Motion gating (sleep/wake on movement) | Up next |
| 4 | Physical ball — drill, insert, waterproof | Up next |
| 5 | Custom PCB + CR2032 + production hardware | Future |
| 6 | FCC/CE cert, App Store, manufacturing | Future |
