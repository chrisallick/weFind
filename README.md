# weFind

A BLE-tracked dog ball. Throw it. Lose it. Open the app. Find it.

No collar. No subscription. No MFi. Works with any iPhone via Bluetooth Low Energy.

---

## Status

**Prototype is working end-to-end.**

- Firmware running on Seeed XIAO BLE Sense (nRF52840)
- iOS app scanning, detecting the ball, and displaying proximity ring
- Next: RSSI threshold calibration in real outdoor conditions

---

## Repo Structure

```
firmware/       Arduino sketch for Seeed XIAO BLE Sense (nRF52840)
ios/            SwiftUI iOS app — Core Bluetooth RSSI proximity
```

## How It Works

The ball advertises a custom BLE UUID. The iOS app scans for that UUID and translates RSSI signal strength into proximity — a ring that grows as you walk toward the ball, with haptic feedback that intensifies as you get close.

No connection required. No account. No internet. Fully local.

## Hardware (Prototype)

| Part | Details |
|---|---|
| Board | Seeed Studio XIAO BLE Sense (nRF52840) |
| Wireless | Bluetooth 5.0, onboard antenna |
| IMU | LSM6DS3TR-C — 6-axis accel/gyro (motion gating, future) |
| Power | LiPo via JST (prototype) → CR2032 coin cell (production target) |
| Size | 21mm × 17.5mm |

## Quick Start

**Firmware:** See [`firmware/README.md`](firmware/README.md)

**iOS App:** See [`ios/README.md`](ios/README.md)

## Proximity UX

The app uses RSSI (signal strength) to estimate distance — no GPS, no UWB, no MFi required.

| Signal | Label |
|---|---|
| Ball detected, far away | "Ball Detected" |
| Walking toward it | "Getting Closer" |
| Within ~40 ft | "Almost There" |
| Standing over it | "Right Here" |

Thresholds are tunable in `BLEManager.swift` — calibrate against your real environment.

## v1 vs v2

**v1 (current):** RSSI proximity — rough but works for finding a ball in tall grass.

**v2 (future, optional):** Precision directional arrow via UWB — requires adding a Qorvo DW3000 chip + MFi enrollment. Deferred.
