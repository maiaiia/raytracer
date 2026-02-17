public typealias World = HittableList

public extension World {
    static var empty: World {
        HittableList()
    }
    static var Book1Scene: World {
        var world = World.empty
        let groundMaterial  = Lambertian(albedo: Color(0.5, 0.5, 0.5))
        world.add(Sphere(center: Point3(0, -1000, -1), radius: 1000, material: groundMaterial))
        
        for a in -11..<11 {
            for b in -11..<11 {
                let chooseMat = randomDouble()
                let center = Point3(Double(a) + 0.9 * randomDouble(), 0.2, Double(b) + 0.9 * randomDouble())
                
                if (center - Point3(4, 0.2, 0)).length <= 0.9 { continue}
                if chooseMat < 0.7 {
                    let albedo = Color.random().hadamard(Color.random())
                    let sphereMaterial = Lambertian(albedo: albedo)
                    world.add(Sphere(center: center, radius: 0.2, material: sphereMaterial))
                } else if chooseMat < 0.95 {
                    let albedo = Color.random().hadamard(Color.random())
                    let fuzz = randomDouble(min: 0, max: 0.5)
                    
                    let sphereMaterial = Metal(albedo: albedo, fuzz: fuzz)
                    world.add(Sphere(center: center, radius: 0.2, material: sphereMaterial))
                } else {
                    world.add(Sphere(center: center, radius: 0.2, material: Dielectric.glass))
                }
            }
        }
        
        world.add(Sphere(center: Point3(0, 1, 0), radius: 1.0, material: Dielectric.glass))
        world.add(Sphere(center: Point3(-4, 1, 0), radius: 1.0, material: Lambertian(albedo: Color.random().hadamard(Color.random()))))
        world.add(Sphere(center: Point3(4, 1, 0), radius: 1.0, material: Metal.gold))
        return world
    }
    
    static var basicScene: World {
        var world: HittableList = HittableList()
        
        let groundMaterial  = Lambertian(albedo: Color(0.5, 0.5, 0.5))
        world.add(Sphere(center: Point3(0, -100.5, -1), radius: 100, material: groundMaterial))
        world.add(Sphere(center: Point3(0, 0, -1.2), radius: 0.5, material: Lambertian(albedo: .red)))
        world.add(Sphere(center: Point3(-1.0, 0, -1), radius: 0.5, material: Metal.copper))
        world.add(Sphere(center: Point3(1, 0, -1), radius: 0.5, material: Metal(albedo: .blue, fuzz: 0.4)))
        world.add(Sphere(center: Point3(-0.5, -0.2, -0.5), radius: 0.2, material: Lambertian(albedo: .magenta)))
        world.add(Sphere(center: Point3(0.5, -0.2, -0.5), radius: 0.2, material: Dielectric.glass))
        world.add(Sphere(center: Point3(0.0, -0.2, -0.5), radius: 0.2, material: Lambertian(albedo: .yellow)))
        
        return world
    }
}
