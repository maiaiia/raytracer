import Foundation

struct Renderer {
    var samplesPerPixel = 10    // count of random samples per pixel
    var maxDepth        = 10    // maximum number of ray bounces into scene
    var parallelism     = true
    
    init(
        samplesPerPixel: Int = 10,
        maxDepth: Int = 10,
        parallelism: Bool = true
    ) {
        self.samplesPerPixel = samplesPerPixel
        self.maxDepth = maxDepth
        self.parallelism = parallelism
    }
    
    // MARK: Ray tracing
    func rayColor<R>(r: Ray, depth: Int, world: any Hittable, rng: inout R) -> Color where R: RandomNumberGenerator {
        if depth <= 0{
            return Color(0, 0, 0)
        }
        if let record = world.hit(r: r, rayT: Interval(0.0001, Double.infinity)) {
            if let scatter = record.material.scatter(ray: r, rec: record, rng: &rng) {
                return scatter.attenuation.hadamard(rayColor(r: scatter.scattered, depth: depth - 1, world: world, rng: &rng))
            } else {
                return Color(0.0, 0.0, 0.0)
            }
        }
        
        // gradient background
        let unitDirection = r.direction().normalized
        let a: Double = 0.5 * (unitDirection.y + 1.0) // lerp
        return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.6, 1.0)
    }
    
    // MARK: Rendering
    
    let bucketSize = 128
    
    func render(
        camera: Camera,
        world: any Hittable
    ) {
        parallelism ?
            renderMultithreaded(camera: camera, world: world) :
            renderSingleThread(camera: camera, world: world)
    }
    
    private func renderSingleThread(camera: Camera, world: any Hittable) {
        let standardError = FileHandle.standardError
        let width = camera.imageWidth
        let height = camera.imageHeight
        
        var renderBuffer = Array(repeating: Color(0, 0, 0), count: height * width)
        var rng = XorShift64(seed: UInt64(0))
        
        for j in 0..<height{
            let message = "\rScanlines remaining: \(height - j) \n"
            standardError.write(message.data(using: .utf8)!)
            for i in 0..<width{
                let currentPixel = j * camera.imageWidth + i
                for _ in 0..<samplesPerPixel{
                    let ray = camera.getRay(i, j, rng: &rng)
                    renderBuffer[currentPixel] += rayColor(r: ray, depth: maxDepth, world: world, rng: &rng)
                }
            }
        }
        
        Renderer.writePPM(width: width, height: height, pixels: renderBuffer, sampleCount: samplesPerPixel)
        standardError.write("\rDone.\n".data(using: .utf8)!)
        
    }
    private func renderMultithreaded(camera: Camera, world: any Hittable) {
        let height = camera.imageHeight
        let width = camera.imageWidth
        
        var renderBuffer = Array(repeating: Color(0, 0, 0), count: height * width)
        
        DispatchQueue.concurrentPerform(iterations: height) { j in
            
            var rng = XorShift64(seed: UInt64(j + 1))
            for i in 0..<width {
                var pixelColor = Color.black
                
                for _ in 0..<samplesPerPixel {
                    let ray = camera.getRay(i, j, rng: &rng)
                    pixelColor += rayColor(
                        r: ray,
                        depth: maxDepth,
                        world: world,
                        rng: &rng
                    )
                }
                
                renderBuffer[j * width + i] = pixelColor
            }
        }
        Renderer.writePPM(width: width, height: height, pixels: renderBuffer, sampleCount: samplesPerPixel)
    }
    
    // MARK: Utils
    static private func writePPM(
        width: Int,
        height: Int,
        pixels: [Color],
        sampleCount: Int
    ) {
        let scale = 1.0 / Double(sampleCount)
        print("P3\n\(width) \(height)\n255")
        for pixel in pixels {
            writeColor(pixelColor: pixel * scale)
        }
    }
}
