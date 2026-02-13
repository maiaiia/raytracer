import Foundation

func main() {
    // World
    var world: HittableList = HittableList()
    
    let groundMaterial = Lambertian(albedo: Color(0.8, 0.8, 0.0))
    let centerMaterial = Lambertian(albedo: Color(0.1, 0.2, 0.5))
    let leftMaterial = Metal(albedo: Color(0.8, 0.8, 0.8))
    let rightMaterial = Metal(albedo: Color(0.8, 0.6, 0.2))
    
    world.add(Sphere(center: Point3(1.5, -100.5, -1), radius: 100, material: groundMaterial))
    world.add(Sphere(center: Point3(0.0, 0.0, -1.2), radius: 0.5, material: centerMaterial))
    world.add(Sphere(center: Point3(-1.5, 0, -1.5), radius: 0.5, material: leftMaterial))
    world.add(Sphere(center: Point3(1.0, 0.0, -1.0), radius: 0.5, material: rightMaterial))
    
    // Render
    let camera = Camera(aspectRatio: 16.0 / 9.0, imageWidth: 400, samplesPerPixel: 100, maxDepth: 50)
    camera.render(world: world)
}

main()
