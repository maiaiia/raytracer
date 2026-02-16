import Foundation

func main() {
    // World
    var world: HittableList = HittableList()
    
    let groundMaterial  = Lambertian(albedo: Color(0.5, 0.5, 0.5))
    world.add(Sphere(center: Point3(0, -100.5, -1), radius: 100, material: groundMaterial))
    world.add(Sphere(center: Point3(0, 0, -1.2), radius: 0.5, material: Lambertian(albedo: .red)))
    world.add(Sphere(center: Point3(-1.0, 0, -1), radius: 0.5, material: Metal.copper))
    world.add(Sphere(center: Point3(1, 0, -1), radius: 0.5, material: Metal(albedo: .blue, fuzz: 0.4)))
    world.add(Sphere(center: Point3(-0.5, -0.2, -0.5), radius: 0.2, material: Lambertian(albedo: .magenta)))
    world.add(Sphere(center: Point3(0.5, -0.2, -0.5), radius: 0.2, material: Dielectric.glass))
    world.add(Sphere(center: Point3(0.0, -0.2, -0.5), radius: 0.2, material: Lambertian(albedo: .yellow)))
    
    // Render
    let camera = Camera(
        aspectRatio: 16.0 / 9.0,
        imageWidth: 600,
        vfov: 50,
        lookFrom: Point3(1, 1, 1),
        lookAt: Point3(0, 0, -1),
        //vUp: Vec3(0, 1, 0),
        defocusAngle: 0.2,
        focusDistance: 1.3,
    )
    
    let singleThreadedRenderer = Renderer(
        samplesPerPixel: 300,
        maxDepth: 50,
        parallelism: false
    )
    let multiThreadedRenderer = Renderer (
        samplesPerPixel: 300,
        maxDepth: 50,
        parallelism: true
    )
    
    let startSingle = Date()
    singleThreadedRenderer.render(camera: camera, world: world)
    let endSingle = Date()
    let singleTime = endSingle.timeIntervalSince(startSingle)
    FileHandle.standardError.write("\rSingle-threaded: \(singleTime) seconds\n ".data(using: .utf8)!)
    
    let startMulti = Date()
    multiThreadedRenderer.render(camera: camera, world: world)
    let endMulti = Date()
    let multiTime = endMulti.timeIntervalSince(startMulti)
    FileHandle.standardError.write("\rMulti-threaded: \(multiTime) seconds\n ".data(using: .utf8)!)
    
    print("\n=== Timing Results ===")
    print("Samples per pixel: 300")
    print("Single-threaded: \(singleTime) seconds\nMulti-threaded: \(multiTime) seconds")
    print("Speedup: \(singleTime / multiTime)x")
}

main()
