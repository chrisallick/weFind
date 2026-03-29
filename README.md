# weFind

A BLE-tracked dog ball. Throw it. Lose it. Open the app. Find it.

No collar. No subscription. No MFi. Works with any iPhone via Bluetooth Low Energy.

---

## Repo Structure

```
firmware/       Arduino sketches for the XIAO BLE Sense (nRF52840)
ios/            SwiftUI iOS app (coming soon)
```

## Quick Start

See [`firmware/README.md`](firmware/README.md) to get BLE advertising running on the hardware in ~10 minutes.

## Hardware

- **BLE chip:** Nordic nRF52840 (via Seeed XIAO BLE Sense)
- **Battery:** CR2032 coin cell (production) / LiPo JST (prototype)
- **Sensors:** LSM6DS3TR-C IMU for motion-gated sleep/wake

## How It Works

The ball advertises a BLE UUID. The iOS app scans for that UUID and translates RSSI signal strength into proximity — "cold / warm / hot" as you walk toward it.
