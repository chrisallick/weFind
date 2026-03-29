# weFind Firmware

Arduino firmware for the **Seeed Studio XIAO BLE Sense (nRF52840)**.

---

## Sketches

### `wefind_advertise`
The prototype sketch. Advertises a custom BLE service UUID so an iPhone can detect the ball via RSSI proximity.

**This is the only sketch you need to validate the core product flow.**

---

## Hardware

- **Board:** [Seeed Studio XIAO BLE Sense — nRF52840](https://www.seeedstudio.com/Seeed-XIAO-BLE-Sense-nRF52840-p-5253.html)
- **Power (prototype):** USB-C to computer, or JST LiPo battery connected to BAT+/BAT- pads
- **Onboard:** nRF52840 + LSM6DS3TR-C IMU (accel/gyro) + PDM mic + BLE 5.0 antenna

---

## Arduino Setup

1. **Install board support**
   - Arduino IDE > Preferences > Additional Board Manager URLs, add:
     ```
     https://files.seeedstudio.com/arduino/package_seeeduino_boards_index.json
     ```
   - Tools > Board > Boards Manager > search "Seeed nRF52" > install

2. **Select board**
   - Tools > Board > Seeed nRF52 Boards > **Seeed XIAO BLE Sense - nRF52840**

3. **Install ArduinoBLE library**
   - Tools > Manage Libraries > search "ArduinoBLE" > install

4. **Upload** `wefind_advertise.ino`

---

## Verifying It Works

1. Upload the sketch — onboard LED should blink green slowly
2. Open **nRF Connect** (free, App Store) on your iPhone
3. Tap **Scan** — you should see **"weFind Ball"** appear
4. Walk toward/away from the board and watch the RSSI value change

That's the full prototype loop. RSSI is what the iOS app will use for proximity.

---

## LED Status

| Color | Pattern | Meaning |
|---|---|---|
| Green | Slow blink (1s) | Advertising OK |
| Red | Fast blink | BLE init failed — wrong board selected |

---

## Next Steps

- [ ] iOS app: scan for `WEFIND_SERVICE_UUID`, display RSSI as proximity
- [ ] Add motion gating using onboard LSM6DS3 IMU (sleep when still)
- [ ] Tune advertising interval for power efficiency
- [ ] Swap to JST LiPo, put in a ball, do a real find test
