# weFind — TODO

---

## Now

- [ ] **Calibrate RSSI thresholds** outdoors — stand at 5ft, 20ft, 50ft, 100ft from board,
      note RSSI values on screen, update `proximityFromRSSI()` in `BLEManager.swift`
- [ ] **Put hardware in a ball** — drill hole in hollow rubber ball, insert board + LiPo, seal
- [ ] **Do a real find test** — throw ball in grass, walk away, use app to find it

---

## iOS App

- [ ] Tune proximity labels to match real outdoor distances
- [ ] Tune haptic pulse rate (faster as you get closer, not just stronger)
- [ ] Add "ball lost" state — when RSSI drops out after being found
- [ ] Add last seen timestamp — "Last seen 2 min ago"
- [ ] Background scanning — notify when ball comes back into range
- [ ] Remove raw RSSI debug readout before shipping

---

## Firmware

- [ ] Implement motion gating — use onboard LSM6DS3 IMU to sleep when ball is still
- [ ] Sleep/wake logic: still for 30s → sleep, motion detected → wake + advertise
- [ ] Tune advertising interval — faster when moving, slower when recently still
- [ ] Validate battery life with a LiPo under realistic conditions

---

## Hardware

- [ ] Switch from LiPo to CR2032 — wire direct to 3V3 pin, bypass BQ25101 charger
- [ ] Find a hollow rubber ball that fits the XIAO board + battery
- [ ] Waterproofing — conformal coat PCB, silicone seal cavity

---

## Production (later)

- [ ] Design custom PCB — nRF52832 + ADXL362 + CR2032 holder, ~25mm diameter
- [ ] FCC/CE certification — use pre-certified module (Raytac MDBT40) to reduce burden
- [ ] App Store submission
- [ ] v2 precision arrow — Qorvo DW3000 UWB chip + MFi enrollment (optional)
