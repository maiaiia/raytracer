import Foundation

func main() {
    // World
    var world: HittableList = HittableList()
    world.add(Sphere(center: Point3(0, 0, -1), radius: 0.5))
    world.add(Sphere(center: Point3(1.5, -100.5, -1), radius: 100))
    
    // Render
    let camera = Camera(aspectRatio: 16.0 / 9.0, imageWidth: 400)
    camera.render(world: world)
}

main()
