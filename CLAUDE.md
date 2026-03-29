# weFind — Dog Ball with BLE Tracking

A hardware + software product that embeds a BLE chip and accelerometer inside a
dog ball, paired with a dedicated native iOS app for proximity-based finding.

---

## Vision

Throw the ball. Lose it in tall grass. Open the app. Find it instantly.

No collar. No subscription. No MFi approval. Works with any iPhone via
Bluetooth Low Energy — no third-party relay network needed.

---

## Architecture Decision (Resolved)

**BLE-only. No MFi Program. No Find My Network.**

- The Find My relay (crowdsourced location when ball is far away) is NOT needed
  for fetch. If your ball is miles away, BLE won't help anyway.
- The core use case — finding a ball in tall grass nearby — is entirely solvable
  with BLE proximity detection from your own app.
- Skipping MFi means no approval process, no NDAs, no certification overhead.
  Prototype today, ship when ready.
- Trade-off accepted: no precision UWB directional arrow (NINearbyAccessoryConfiguration
  requires MFi-level Apple cooperation). RSSI-based proximity is the v1 UX.

---

## Project Phases

### Phase 0 — Toolchain Setup (start here)

- [ ] Order **nRF52840 DK** dev board (~$50) from Nordic or Digi-Key
- [ ] Install **nRF Connect SDK** + VS Code extension
      https://www.nordicsemi.com/Products/Development-hardware/nRF52840-DK
- [ ] Install **nRF Connect for Desktop** (flashing + serial monitor)
- [ ] Verify toolchain works: build and flash the `blinky` sample

---

### Phase 1 — Hardware Prototype

**Goal:** Get a chip advertising over BLE, detectable by your iPhone. Add motion
gating so the chip sleeps when the ball is still.

#### Chip Selection

| Chip | Role | Notes |
|---|---|---|
| **Nordic nRF52840** | Prototype | More RAM/flash, easier to dev on |
| **Nordic nRF52832** | Production target | Smaller, lower power, same SDK |

Both run the same nRF Connect SDK. Start on 52840 DK, target 52832 for final hardware.

#### Accelerometer (Motion Gating)

Add a low-power accelerometer wired to a GPIO interrupt on the nRF52. This is
the key to excellent battery life.

| Chip | Current (sleep) | Notes |
|---|---|---|
| **ADXL362** | ~270nA | Best choice — ultra-low power, motion interrupt |
| LIS2DH12 | ~500nA | Common, well-supported, slightly higher power |
| LIS3DH | ~2µA | Widely available, easy to source |

Recommended: **ADXL362** — its motion-triggered wakeup draws less than a quarter
of a microamp in watch mode. Wire INT1 to nRF52 GPIO.

#### Power Architecture

**Two power states:**

| State | What's happening | Estimated draw |
|---|---|---|
| **Deep sleep** | Ball is still. nRF52 in System OFF. Accel watching for motion. | ~0.3–1µA total |
| **Active** | Ball is moving or was recently thrown. BLE advertising. | ~10–20µA avg |

**Battery math (CR2032, 225mAh):**

Assuming ball is active 1 hour/day and sleeping 23 hours:
```
Active:  1h × 15µA  =   15µAh/day
Sleep:  23h × 0.5µA =   11.5µAh/day
Total:              ≈   27µAh/day

225,000µAh / 27µAh = ~8,300 days → not realistic (self-discharge limits CR2032)
Practical limit: CR2032 self-discharges in ~3–5 years on the shelf

Realistic estimate: 2–3 years of normal use. 6 months is extremely conservative.
```

CR2032 is the right call. Replaceable, no charging infrastructure needed.

#### Motion Gating Logic (Firmware)

```
Boot → start BLE advertising
Ball still for 30s → enter deep sleep (accel watching)
Motion detected → wake up → BLE advertising resumes
```

Advertising interval tuning:
- Active/moving: 100–200ms interval (responsive, ~15µA avg)
- Recently landed: 1s interval (still findable, ~5µA avg)
- After 30s no movement: sleep

#### Firmware Checklist

- [ ] Set up nRF Connect SDK, build `blinky` sample on nRF52840 DK
- [ ] Build BLE peripheral with custom service + characteristic (UUID for ball ID,
      battery level)
- [ ] Implement RSSI-friendly advertising (consistent TX power, iBeacon-style or
      custom advertisement packet)
- [ ] Wire ADXL362 via SPI, configure motion interrupt on INT1
- [ ] Implement System OFF sleep mode, GPIO wakeup from accel interrupt
- [ ] Tune advertising intervals (active vs. recently-still vs. sleep)
- [ ] Validate battery life estimate with a current meter

---

### Phase 2 — iOS App (start in parallel with Phase 1)

**Goal:** A focused, single-purpose app. Find your ball. Nothing more.

#### App Stack

- **Language:** Swift
- **Framework:** SwiftUI
- **BLE:** Core Bluetooth (CBCentralManager)
- **Proximity:** RSSI-based distance estimation
- **Minimum iOS:** iOS 14+
- **No MFi, no NearbyInteraction, no Find My dependencies**

#### How BLE Proximity Works

The app scans for the ball's BLE advertisement by UUID. As the user walks toward
the ball, RSSI increases (less negative = stronger signal = closer). The app
translates RSSI to a rough distance and UX cue.

RSSI is noisy — smooth it with a rolling average (Kalman filter or simple
exponential moving average). Don't show a raw number; show a range:
"Very close", "Getting closer", "Far".

#### App Features — v1 (MVP)

- [ ] Onboarding: scan for ball, pair by UUID, name it
- [ ] Home screen: connection status + last seen time
- [ ] Finding mode: big visual indicator (signal strength ring / progress bar)
      that grows as you get closer — like a "hot/cold" game
- [ ] Haptic feedback: pulses get faster/stronger as RSSI increases
- [ ] "Ball found" confirmation when RSSI exceeds close-range threshold
- [ ] Background scanning: notify user when ball comes into BLE range
      (useful when you've left it somewhere and come back)
- [ ] Battery level display (read from BLE characteristic)

#### App Features — v2

- [ ] Multiple balls
- [ ] Throw history / heatmap
- [ ] "Throw mode" — session tracking, auto-notify when ball stops moving
      (ball advertises accelerometer state; app reads it)
- [ ] Apple Watch companion
- [ ] If MFi ever pursued: upgrade to NINearbyAccessoryConfiguration for
      precision directional arrow

#### App Architecture Notes

- Use `CBCentralManager` for scanning and `CBPeripheral` for connecting
- Scan for the ball's service UUID without connecting for proximity (faster,
  lower power on phone side)
- Only connect to read battery level or accelerometer state
- Background BLE scanning requires `bluetooth-central` background mode in
  Info.plist — works on iOS, Apple may ask about it during App Store review
  but it's approved for accessory companion apps

---

### Phase 3 — Physical Ball Design

**Goal:** Get the electronics inside something a dog can actually use.

- [ ] Prototype with off-the-shelf hollow rubber ball (drill, insert, seal)
- [ ] Design chip + battery + accel PCB to fit in ~25mm diameter
- [ ] Waterproofing: conformal coat PCB, silicone pot the whole assembly
- [ ] Durability testing: drop, chew, wet grass
- [ ] Work with a product designer on injection-molded cavity in production ball
- [ ] Battery compartment: twist-off rubber plug for CR2032 replacement

---

### Phase 4 — Productization (if/when ready to ship)

- [ ] FCC/CE certification for BLE device (required to sell)
      — use a pre-certified module (Raytac MDBT40, u-blox NINA-B1) to reduce burden
- [ ] App Store submission
- [ ] If Find My relay is ever desired: revisit MFi Program at this stage
- [ ] Manufacturing partner for ball production

---

## Key Decisions & Open Questions

| Question | Status |
|---|---|
| MFi / Find My Network | RESOLVED — skipping for now. BLE-only. |
| Battery | RESOLVED — CR2032 replaceable coin cell |
| Charging | RESOLVED — no charging, replaceable battery |
| Precision UWB direction finding | DEFERRED — requires MFi. v2 if pursued. |
| Ball material / durability | TBD — need a product designer |
| Waterproofing strategy | Required — dogs, grass, puddles |
| Single ball SKU or multiple sizes? | TBD |
| App monetization | TBD |
| Manufacturing partner | TBD |

---

## Tech Stack Summary

| Layer | Technology |
|---|---|
| BLE Chip | Nordic nRF52840 (proto) → nRF52832 (production) |
| Motion Sensor | ADXL362 (ultra-low power, SPI, motion interrupt) |
| Firmware | nRF Connect SDK, custom BLE peripheral + sleep/wake logic |
| Battery | CR2032 coin cell, replaceable |
| iOS App | Swift + SwiftUI + Core Bluetooth |
| Proximity | RSSI-based distance estimation with smoothing |
| Backend | None — fully local |

---

## Resources

- nRF52840 DK dev board: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-DK
- nRF Connect SDK: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-DK
- nRF Connect for Desktop: https://www.nordicsemi.com/Products/Development-tools/nRF-Connect-for-Desktop
- ADXL362 datasheet: https://www.analog.com/en/products/adxl362.html
- Raytac MDBT40 (pre-certified nRF52832 module): https://www.raytac.com
- Core Bluetooth docs: https://developer.apple.com/documentation/corebluetooth
- Apple BLE background modes: https://developer.apple.com/documentation/corebluetooth/performing_common_central_role_tasks

---

## Immediate Next Actions

1. Order **nRF52840 DK** dev board — you can start firmware the day it arrives
2. Install **nRF Connect SDK** + VS Code extension now (don't wait for hardware)
3. Order **ADXL362 breakout board** (Sparkfun or Adafruit carry them) for accel prototyping
4. Start the **iOS Xcode project** — scaffold SwiftUI views, stub CBCentralManager scanning
5. First firmware milestone: nRF52840 DK advertising a custom BLE UUID, visible
   in nRF Connect mobile app
