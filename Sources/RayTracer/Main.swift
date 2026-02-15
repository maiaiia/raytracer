import Foundation

func main() {
    // World
    var world: HittableList = HittableList()
    
    let groundMaterial  = Lambertian(albedo: Color(0.5, 0.5, 0.5))
    world.add(Sphere(center: Point3(0, -100.5, -1), radius: 100, material: groundMaterial))
    world.add(Sphere(center: Point3(0, 0, -1.2), radius: 0.5, material: Lambertian(albedo: .red)))
    world.add(Sphere(center: Point3(-1.0, 0, -1), radius: 0.5, material: Lambertian(albedo: .green)))
    world.add(Sphere(center: Point3(1, 0, -1), radius: 0.5, material: Lambertian(albedo: .blue)))
    world.add(Sphere(center: Point3(-0.5, -0.5, -0.5), radius: 0.2, material: Lambertian(albedo: .magenta)))
    world.add(Sphere(center: Point3(0.5, -0.5, -0.5), radius: 0.2, material: Lambertian(albedo: .cyan)))
    
    // Render
    let camera = Camera(
        aspectRatio: 16.0 / 9.0,
        imageWidth: 400,
        vfov: 5,
        lookFrom: Point3(1, 1, 1),
        lookAt: Point3(0, 0, -1),
        //vUp: Vec3(0, 1, 0),
        //defocusAngle: 0.6,
        //focusDistance: 10.0,
    )
    let renderer = Renderer(
        samplesPerPixel: 200,
        maxDepth: 50,
    )
    renderer.render(camera: camera, world: world)
}

main()
