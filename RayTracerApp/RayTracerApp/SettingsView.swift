import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: RayTracerSettings
    
    init(settings: RayTracerSettings) {
        self.settings = settings
    }
    
    let scenes = ["Lucy In One Weekend", "Cornell Box", "Random Spheres", "Simple Light"]
    
    var body: some View {
        ZStack {
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Scene Section
                        SectionView(title: "Scene") {
                            VStack(spacing: 12) {
                                Menu {
                                    ForEach(scenes, id: \.self) { scene in
                                        Button(scene) {
                                            settings.selectedScene = scene
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(settings.selectedScene)
                                            .foregroundColor(.white)
                                            .font(.system(size: 14, design: .monospaced))
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(Color(hex: "4a90e2"))
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(Color(hex: "2a2a2a"))
                                    .cornerRadius(6)
                                }
                                
                                ToggleRow(title: "Show statistics overlay", isOn: $settings.showStatistics)
                            }
                        }
                        
                        // Ray Tracing Section
                        SectionView(title: "Ray Tracing") {
                            VStack(spacing: 12) {
                                ToggleRow(title: "Accumulate rays between frames", isOn: $settings.accumulateRays)
                                
                                SliderRow(title: "Samples", value: $settings.samples, range: 1...100, step: 1)
                                SliderRow(title: "Bounces", value: $settings.bounces, range: 10...1000, step: 10)
                            }
                        }
                        
                        // Camera Section
                        SectionView(title: "Camera") {
                            VStack(spacing: 12) {
                                SliderRow(title: "FoV", value: $settings.fov, range: 10...120, step: 1)
                                SliderRow(title: "Aperture", value: $settings.aperture, range: 0.01...1.0, step: 0.01, decimalPlaces: 2)
                                SliderRow(title: "Focus", value: $settings.focus, range: 0.1...20.0, step: 0.1, decimalPlaces: 1)
                                
                                ToggleRow(title: "Apply gamma correction", isOn: $settings.applyGammaCorrection)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
                .textCase(.uppercase)
                .tracking(0.5)
            
            content
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(isOn ? Color(hex: "4a90e2") : .gray)
                .font(.system(size: 16))
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 14, design: .monospaced))
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isOn.toggle()
            }
        }
    }
}

struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var decimalPlaces: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Slider(value: $value, in: range, step: step)
                    .accentColor(Color(hex: "4a90e2"))
                
                Text(formatValue(value))
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .frame(width: 60, alignment: .trailing)
                
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 13, design: .monospaced))
                    .frame(minWidth: 70, alignment: .trailing)
            }
        }
    }
    
    private func formatValue(_ val: Double) -> String {
        if decimalPlaces == 0 {
            return String(format: "%.0f", val)
        } else {
            return String(format: "%.\(decimalPlaces)f", val)
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SettingsView(settings: RayTracerSettings())
}
