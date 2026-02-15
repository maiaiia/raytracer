import Foundation
struct Renderer {
    var samplesPerPixel = 10    // count of random samples per pixel
    var maxDepth        = 10    // maximum number of ray bounces into scene
    
    private var pixelSamplesScale:  Double    // final image height
    
    init(
        samplesPerPixel: Int = 10,
        maxDepth: Int = 10,
    ) {
        self.samplesPerPixel = samplesPerPixel
        self.maxDepth = maxDepth
        
        self.pixelSamplesScale = 1.0 / Double(samplesPerPixel)
    }
    
    // MARK: Rendering
    func render(
        camera: Camera,
        world: any Hittable
    ) {
        //self.init()
        let standardError = FileHandle.standardError
        print("P3\n\(camera.imageWidth) \(camera.imageHeight)\n255")
        for j in 0..<camera.imageHeight{
            let message = "\rScanlines remaining: \(camera.imageHeight - j) \n"
            standardError.write(message.data(using: .utf8)!)
            for i in 0..<camera.imageWidth{
                var pixelColor = Color(0, 0, 0)
                for _ in 0..<samplesPerPixel{
                    let ray = camera.getRay(i, j)
                    pixelColor += rayColor(r: ray, depth: maxDepth, world: world)
                }
                writeColor(pixelColor: pixelColor * pixelSamplesScale)
            }
        }
        standardError.write("\rDone.\n".data(using: .utf8)!)
    }
    
    // MARK: Ray tracing
    func rayColor(r: Ray, depth: Int, world: any Hittable) -> Color {
        if depth <= 0{
            return Color(0, 0, 0)
        }
        if let record = world.hit(r: r, rayT: Interval(0.0001, Double.infinity)) {
            if let scatter = record.material.scatter(ray: r, rec: record) {
                return scatter.attenuation.hadamard(rayColor(r: scatter.scattered, depth: depth - 1, world: world))
            } else {
                return Color(0.0, 0.0, 0.0)
            }
        }
        
        // gradient background
        let unitDirection = r.direction().normalized
        let a: Double = 0.5 * (unitDirection.y + 1.0) // lerp
        return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.6, 1.0)
    }
}
