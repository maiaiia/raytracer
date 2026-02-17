import Foundation
import RayTracerCore

func main() {
    // World
    var world = World.Book1Scene
    
    // Render
    let camera = Camera(
        aspectRatio: 16.0 / 9.0,
        imageWidth: 400,
        vfov: 20,
        lookFrom: Point3(13, 2, 3),
        lookAt: Point3(0, 0, 0),
        vUp: Vec3(0, 1, 0),
        defocusAngle: 0.6,
        focusDistance: 10.0,
    )
    let multiThreadedRenderer = Renderer (
        samplesPerPixel: 100,
        maxDepth: 50,
        parallelism: true
    )
    
    let startMulti = Date()
    multiThreadedRenderer.render(camera: camera, world: world)
    let endMulti = Date()
    let multiTime = endMulti.timeIntervalSince(startMulti)
    FileHandle.standardError.write("\rMulti-threaded: \(multiTime) seconds\n ".data(using: .utf8)!)
    
}

main()
