// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "raytracer",
    products: [
        .library(
            name: "RayTracer",  // Product name
            targets: ["RayTracer"]),
    ],
    targets: [
        .target(
            name: "RayTracer"),
    ]
)


