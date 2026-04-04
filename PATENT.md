# weFind — Invention Disclosure Document

This document is a structured description of the weFind invention, written to support
a provisional or non-provisional patent application. It is not a legal filing — it is
a technical record of the invention to share with a patent attorney or to use as the
basis for a USPTO Pro Se provisional application.

**Inventor:** [Your full legal name]
**Date of first reduction to practice:** March 2026 (working prototype)
**Filing target:** Provisional patent application

---

## 1. Title of Invention

**BLE-Embedded Animal Toy with RSSI-Based Proximity Detection System**

(Alternative titles: "Wireless Tracking System Integrated into a Pet Toy" /
"Bluetooth-Enabled Retrievable Ball with Mobile Proximity Interface")

---

## 2. Field of the Invention

This invention relates to pet accessories, specifically to a throwable toy (a ball)
that incorporates a Bluetooth Low Energy (BLE) radio transmitter inside its body,
paired with a mobile application that guides the user to the toy's location using
signal strength (RSSI) proximity estimation.

---

## 3. Background / Problem Being Solved

Pet owners — particularly dog owners — frequently lose thrown toys in tall grass,
dense vegetation, water, snow, or low-light environments. Existing solutions are
inadequate:

- **GPS trackers** are too large, require subscriptions, and have poor short-range
  accuracy (GPS accuracy is ~3–5 meters at best).
- **Dog collars with trackers** solve a different problem (tracking the animal,
  not the toy).
- **Apple AirTag / Find My network** requires MFi licensing from Apple, involves
  significant legal/NDA overhead, and is not designed for integration into
  impact-tolerant consumer goods.
- **UWB-based direction finding** (e.g., AirTag precision finding) requires MFi
  enrollment and specialized UWB chips (e.g., Qorvo DW3000), adding cost and
  regulatory complexity.

**The gap:** No existing product embeds a BLE radio directly inside a throwable dog
toy with a paired app that provides real-time proximity guidance — without requiring
GPS, subscription services, proprietary network enrollment, or device pairing.

---

## 4. Summary of the Invention

The invention is a system comprising two components:

1. **The Ball** — A throwable pet toy containing an embedded BLE radio module,
   power source, and optional inertial measurement unit (IMU), sealed inside the
   toy body.

2. **The Mobile Application** — A smartphone app that passively scans for the
   ball's BLE advertisement without establishing a connection, translates received
   signal strength (RSSI) into a proximity estimate, and presents this to the user
   as a visual proximity indicator with haptic feedback.

The system requires no pairing, no internet connection, no subscription, and no
proprietary network access. Detection works entirely through BLE advertisement
packets that the ball continuously broadcasts.

---

## 5. Detailed Description of the Invention

### 5.1 The Embedded Hardware (The Ball)

The ball contains a compact BLE System-on-Chip (SoC) that continuously broadcasts
a BLE advertisement packet containing a custom 128-bit service UUID. The UUID serves
as the unique identifier for the device, allowing the mobile app to distinguish the
ball from other BLE devices in the environment.

**Prototype implementation:**
- SoC: Nordic Semiconductor nRF52840 (via Seeed Studio XIAO BLE Sense module)
- Dimensions: 21mm × 17.5mm
- BLE version: Bluetooth 5.0
- Advertising interval: 100ms (non-connectable, undirected advertising)
- TX power included in advertisement (allows app-side distance estimation refinement)
- Power source: LiPo rechargeable battery (prototype); CR2032 coin cell (production target)
- Optional IMU: LSM6DS3TR-C 6-axis accelerometer/gyroscope for motion-gated power management

**Production target:**
- Custom PCB: ~25mm diameter circular board
- SoC: nRF52832 (smaller, lower power than nRF52840)
- IMU: ADXL362 (ultra-low-power accelerometer for motion gating)
- Battery: CR2032 coin cell (2–3 year estimated life)
- Enclosure: Embedded inside hollow rubber ball; PCB and battery sealed with
  conformal coating and silicone

### 5.2 BLE Advertisement Protocol

The ball broadcasts continuously using non-connectable BLE advertising (ADV_NONCONN_IND
or equivalent), meaning no GATT connection is ever established. The advertisement
packet includes:

- Custom 128-bit service UUID: identifies the device as a weFind ball
- Device name: "weFind Ball"
- TX power level: included for optional distance calculation by the receiver
- Advertising flags: General Discoverable Mode, LE Only

The use of non-connectable advertising (as opposed to connectable) means:
- Lower power consumption on the ball
- Faster detection by the phone (no connection handshake)
- No limit on number of simultaneous scanning phones

### 5.3 The Mobile Application

The mobile application uses the platform's native BLE scanning API (e.g., Core
Bluetooth on iOS) to scan for the ball's custom service UUID. Key behaviors:

**Scanning:**
- Scans specifically for the ball's UUID — filters out all other BLE devices
- Enables duplicate advertisement reception to receive continuous RSSI updates
  (CBCentralManagerScanOptionAllowDuplicatesKey on iOS)
- No connection established — purely advertisement-based detection

**RSSI Smoothing:**
- Raw RSSI values are noisy due to multipath propagation and environmental factors
- The app applies an Exponential Moving Average (EMA) to smooth readings:
  `smoothed = α × raw + (1 − α) × previous_smoothed`
  where α = 0.2 (smoothing factor, tunable)
- The EMA is seeded with the first valid reading to avoid startup transients

**Proximity Estimation:**
- Smoothed RSSI is mapped to discrete proximity states using calibrated thresholds:

  | RSSI Range (dBm) | Proximity State | Meaning |
  |---|---|---|
  | ≥ −55 | Very Close | Standing over the ball (~4–8 ft) |
  | −70 to −55 | Close | Almost there (~15–40 ft) |
  | −85 to −70 | Near | Getting closer (~40–80 ft) |
  | < −85 | Far | Ball detected, far away (~80–200 ft) |

- Thresholds are calibrated at known distances in real environments
- States are tunable via constants in the application source

**User Interface:**
- A proximity ring scales from small to full-screen as the user approaches the ball
- Ring color changes with proximity state (gray → blue → yellow → orange → green)
- Haptic feedback intensity increases as the user gets closer
- Proximity label displayed in plain language ("Getting Closer", "Right Here", etc.)
- Raw RSSI value displayed for calibration (to be removed in shipping version)

### 5.4 Motion-Gated Power Management (Planned)

To extend battery life, the embedded IMU will detect when the ball is stationary
(e.g., sitting in a yard between throws) and enter a low-power sleep state,
suspending BLE advertising. Upon detecting motion (throw, movement), the device
wakes and resumes advertising within milliseconds.

- Sleep trigger: no significant acceleration for ~30 seconds
- Wake trigger: acceleration above a threshold on any axis
- Advertising rate: potentially increased immediately after wake (ball was just thrown)
  and reduced while stationary

---

## 6. Claims (Draft — for attorney review)

These are the inventor's proposed claims. A patent attorney should refine scope,
independence, and language before filing.

### Independent Claims

**Claim 1.**
A system for locating a throwable pet toy, comprising:
- a throwable toy body having an interior cavity;
- a Bluetooth Low Energy radio module disposed within the interior cavity, configured
  to continuously broadcast a non-connectable BLE advertisement packet comprising a
  device-specific identifier;
- a power source disposed within the interior cavity and electrically connected to
  the radio module; and
- a mobile application executing on a user's smartphone, configured to:
  - scan for BLE advertisement packets matching the device-specific identifier without
    establishing a BLE connection to the radio module;
  - receive signal strength measurements from successive advertisement packets;
  - apply a smoothing algorithm to the signal strength measurements; and
  - present a proximity indicator to the user based on the smoothed signal strength.

**Claim 2.**
A method for guiding a user to a lost throwable pet toy, comprising:
- continuously broadcasting, from within the body of a throwable pet toy, a BLE
  advertisement packet containing a unique device identifier;
- scanning, by a mobile application on a user's smartphone, for BLE advertisement
  packets matching the unique device identifier without establishing a BLE connection;
- receiving, at the mobile application, a sequence of received signal strength
  indicator (RSSI) values from successive advertisement packets;
- computing a smoothed signal strength estimate by applying an exponential moving
  average to the RSSI sequence; and
- presenting a scaled visual proximity indicator to the user that varies
  continuously with the smoothed signal strength estimate.

### Dependent Claims

**Claim 3.** The system of Claim 1, wherein the radio module further comprises an
inertial measurement unit configured to detect motion of the toy body, and wherein
the radio module suspends BLE advertising when no motion is detected for a
predetermined period and resumes advertising upon detecting motion.

**Claim 4.** The system of Claim 1, wherein the proximity indicator comprises a
ring displayed on the smartphone screen that scales in size as the user approaches
the toy.

**Claim 5.** The system of Claim 1, wherein the mobile application further provides
haptic feedback that increases in intensity as the smoothed signal strength increases.

**Claim 6.** The system of Claim 1, wherein the toy body is a rubber ball.

**Claim 7.** The system of Claim 1, wherein the power source is a coin cell battery.

**Claim 8.** The system of Claim 1, wherein the BLE advertisement packet includes a
TX power level field, and wherein the mobile application uses the TX power level to
refine the proximity estimate.

---

## 7. Drawings / Figures Needed

For a formal application, the following figures should be prepared:

- **Figure 1** — System overview: ball with embedded hardware + smartphone with app
- **Figure 2** — Cross-section of ball showing embedded PCB, battery, and antenna
- **Figure 3** — BLE advertisement packet structure
- **Figure 4** — Mobile app UI: proximity ring states (far → very close)
- **Figure 5** — RSSI smoothing diagram: raw vs. EMA-smoothed signal over time
- **Figure 6** — Proximity state machine / threshold diagram
- **Figure 7** — Motion gating state machine (sleep/wake based on IMU)
- **Figure 8** — Custom PCB layout (production target)

---

## 8. Prior Art to Distinguish

A patent attorney will conduct a formal prior art search. Inventor-identified
prior art to distinguish:

- **Apple AirTag / Find My network** — Requires MFi licensing; uses UWB for
  precision finding; not designed for integration into impact-tolerant toys;
  relies on Apple's proprietary crowdsourced network.
- **Tile / Chipolo / similar BLE trackers** — Standalone tracker devices, not
  integrated into pet toys; require account/app ecosystem.
- **GPS pet trackers (Whistle, Fi, Tractive)** — Collar-based; require cellular
  subscription; designed to track animals, not toys.
- **US Patent [search needed]** — Search terms: "BLE toy tracking", "Bluetooth
  pet toy", "RSSI proximity toy locator", "embedded BLE sports equipment"

---

## 9. Inventor Statement

I conceived of this invention to solve the specific problem of losing dog toys
in outdoor environments. The key insight is that BLE advertisement-based proximity
detection — without pairing, without network enrollment, and without GPS — is
sufficient for the fetch use case, and small enough to embed directly inside a
standard pet toy. The working prototype (March 2026) demonstrates all core
claims: the embedded hardware, the non-connectable BLE advertising, RSSI-based
proximity estimation with EMA smoothing, and the proximity ring UI with haptics.

Signature: _________________________________ Date: _______________

---

## 10. Next Steps

- [ ] Have a patent attorney review and refine the claims in Sections 6
- [ ] Conduct a formal prior art search (USPTO Patent Full-Text Database, Google Patents)
- [ ] Prepare formal drawings (Sections 7) — patent drawings have specific formatting rules
- [ ] File provisional patent application with USPTO (~$320 small entity filing fee)
- [ ] Set a reminder: non-provisional must be filed within 12 months of provisional
- [ ] Consider: international filing via PCT if global market is a goal
