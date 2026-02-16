import SwiftUI
import Combine

class RayTracerSettings: ObservableObject {
    @Published var selectedScene = "Scene 1"
    @Published var showStatistics = true
    @Published var accumulateRays = true
    @Published var samples: Double = 8
    @Published var bounces: Double = 16
    @Published var fov: Double = 20
    @Published var aperture: Double = 0.16
    @Published var focus: Double = 13.1
    @Published var applyGammaCorrection = true
    
    let scenes = ["Scene 1", "Scene 2", "Scene 3"]
}
