import SwiftUI
import CoreHaptics

struct ContentView: View {
    @StateObject private var ble = BLEManager()
    @State private var engine: CHHapticEngine?
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Proximity ring
                ZStack {
                    // Outer pulse ring
                    Circle()
                        .stroke(ble.proximity.color.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)
                        .scaleEffect(pulseScale)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)

                    // Main ring — grows with proximity
                    Circle()
                        .stroke(ble.proximity.color, lineWidth: 6)
                        .frame(
                            width: CGFloat(100 + 160 * ble.proximity.scale),
                            height: CGFloat(100 + 160 * ble.proximity.scale)
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: ble.proximity.scale)

                    // Center label
                    VStack(spacing: 8) {
                        if ble.ballFound {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(ble.proximity.color)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .scaleEffect(1.5)
                        }

                        Text(ble.proximity.label)
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .animation(.easeInOut, value: ble.proximity.label)
                    }
                }

                // RSSI debug readout
                if ble.ballFound {
                    Text("Signal: \(ble.rssi) dBm")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                }

                Spacer()

                // Status footer
                HStack(spacing: 8) {
                    Circle()
                        .fill(ble.ballFound ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(ble.ballFound ? "weFind Ball detected" : "Looking for ball...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            prepareHaptics()
            pulseScale = 1.08
        }
        .onChange(of: ble.proximity) { _ in
            triggerHaptic(for: ble.proximity)
        }
    }

    // MARK: - Haptics

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    private func triggerHaptic(for proximity: Proximity) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics,
              let engine else { return }

        let intensity: Float
        switch proximity {
        case .unknown, .far: return  // no haptic when far/unknown
        case .near:          intensity = 0.3
        case .close:         intensity = 0.6
        case .veryClose:     intensity = 1.0
        }

        let hapticEvent = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        )

        let pattern = try? CHHapticPattern(events: [hapticEvent], parameters: [])
        let player = try? engine.makePlayer(with: pattern!)
        try? player?.start(atTime: 0)
    }
}

#Preview {
    ContentView()
}
