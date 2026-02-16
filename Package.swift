// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "raytracer",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "RayTracerCore",
            targets: ["RayTracerCore"]
        ),
        .executable(
            name: "RayTracer",
            targets: ["RayTracerCLI"]
        ),
    ],
    targets: [
        .target(
            name: "RayTracerCore"
        ),
        .executableTarget(
            name: "RayTracerCLI",
            dependencies: ["RayTracerCore"]
        ),
    ]
)
