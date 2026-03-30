# weFind iOS App

SwiftUI app that scans for the weFind ball over BLE and displays RSSI-based proximity.

---

## Setup

1. **Create a new Xcode project**
   - File > New > Project > iOS > App
   - Product Name: `weFind`
   - Interface: SwiftUI
   - Language: Swift

2. **Replace the generated files** with the ones in `ios/weFind/`:
   - `weFindApp.swift`
   - `ContentView.swift`
   - `BLEManager.swift`

3. **Add Bluetooth permissions** to `Info.plist`:
   ```
   NSBluetoothAlwaysUsageDescription
   → "weFind uses Bluetooth to locate your ball."
   ```

4. **Add Background Mode** (optional — for background scanning):
   - Target > Signing & Capabilities > + Capability > Background Modes
   - Check **Uses Bluetooth LE accessories**

5. **Run on a real iPhone** — Bluetooth doesn't work in the simulator

---

## How It Works

- Scans for the weFind service UUID without connecting (faster, lower power)
- `CBCentralManagerScanOptionAllowDuplicatesKey: true` gives continuous RSSI updates
- RSSI smoothed with exponential moving average (EMA) to reduce noise
- Proximity ring grows and changes color as you get closer
- Haptic feedback intensifies as proximity increases

## Proximity Thresholds

These are starting points — tune them based on real-world testing with your hardware:

| RSSI | Proximity |
|---|---|
| < -85 dBm | Far |
| -85 to -70 dBm | Getting Closer |
| -70 to -55 dBm | Close |
| > -55 dBm | Right Here |

The raw RSSI value is shown on screen during testing to help calibrate.
