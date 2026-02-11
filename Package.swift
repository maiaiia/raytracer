// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "raytracer",
    products: [
        .executable(
            name: "RayTracer",  // Product name
            targets: ["RayTracer"]),
    ],
    targets: [
        .executableTarget(
            name: "RayTracer"),
    ]
)


