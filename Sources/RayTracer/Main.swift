import Foundation

func main() {
    // World
    var world: HittableList = HittableList()
    
    let R = cos(Double.pi / 4)
    let leftMaterial = Lambertian(albedo: Color(0, 0, 1))
    let rightMaterial = Lambertian(albedo: Color(1, 0, 0))
    /*
    let leftMaterial = Dielectric(refractionIndex: 1.00 / 1.33)
    let rightMaterial = Metal(albedo: Color(0.8, 0.6, 0.2), fuzz: 1.0)*/
    
    world.add(Sphere(center: Point3(-R, 0, -1), radius: R, material: leftMaterial))
    world.add(Sphere(center: Point3(R, 0, -1), radius: R, material: rightMaterial))
    
    // Render
    let camera = Camera(aspectRatio: 16.0 / 9.0, imageWidth: 400, samplesPerPixel: 100, maxDepth: 50)
    camera.render(world: world)
}

main()
