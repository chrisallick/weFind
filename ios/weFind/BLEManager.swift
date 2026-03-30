import CoreBluetooth
import Combine

// Service UUID must match firmware exactly
let WEFIND_SERVICE_UUID = CBUUID(string: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")

enum Proximity {
    case unknown
    case far
    case near
    case close
    case veryClose

    var label: String {
        switch self {
        case .unknown:   return "Searching..."
        case .far:       return "Far"
        case .near:      return "Getting Closer"
        case .close:     return "Close"
        case .veryClose: return "Right Here"
        }
    }

    var color: Color {
        switch self {
        case .unknown:   return .gray
        case .far:       return .blue
        case .near:      return .yellow
        case .close:     return .orange
        case .veryClose: return .green
        }
    }

    // Scale 0.0 – 1.0 for the proximity ring
    var scale: Double {
        switch self {
        case .unknown:   return 0.1
        case .far:       return 0.25
        case .near:      return 0.5
        case .close:     return 0.75
        case .veryClose: return 1.0
        }
    }
}

import SwiftUI

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var isScanning = false
    @Published var ballFound = false
    @Published var rssi: Int = -100
    @Published var smoothedRSSI: Double = -100
    @Published var proximity: Proximity = .unknown

    private var centralManager: CBCentralManager!
    private var smoothingFactor: Double = 0.2  // EMA smoothing (0 = no update, 1 = no smoothing)

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Scanning

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        // Scan without connecting — faster, lower power
        centralManager.scanForPeripherals(
            withServices: [WEFIND_SERVICE_UUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]  // needed for continuous RSSI updates
        )
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        ballFound = false
        proximity = .unknown
        smoothedRSSI = -100
    }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            isScanning = false
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        let raw = RSSI.intValue
        guard raw != 127 else { return }  // 127 = RSSI not available

        ballFound = true
        rssi = raw

        // Exponential moving average smoothing
        if smoothedRSSI == -100 {
            smoothedRSSI = Double(raw)  // seed with first reading
        } else {
            smoothedRSSI = smoothingFactor * Double(raw) + (1 - smoothingFactor) * smoothedRSSI
        }

        proximity = proximityFromRSSI(smoothedRSSI)
    }

    // MARK: - RSSI → Proximity

    // These thresholds are starting points — tune them with your actual hardware.
    // RSSI values are negative; closer to 0 = stronger signal = closer.
    private func proximityFromRSSI(_ rssi: Double) -> Proximity {
        if rssi >= -55 { return .veryClose }
        if rssi >= -70 { return .close }
        if rssi >= -85 { return .near }
        return .far
    }
}
