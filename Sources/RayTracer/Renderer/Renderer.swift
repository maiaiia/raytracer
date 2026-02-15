import Foundation

class RenderBuffer {
    var pixels: [Color]
    init (size: Int) {
        pixels = Array(repeating: Color(0, 0, 0), count: size)
    }
    // TODO - make render buffer conform to Sequence
}

struct Renderer {
    var samplesPerPixel = 10    // count of random samples per pixel
    var maxDepth        = 10    // maximum number of ray bounces into scene
    var parallelism     = true
    
    private var pixelSamplesScale:  Double    // final image height
    private var buffer: [Color] = []
    
    init(
        samplesPerPixel: Int = 10,
        maxDepth: Int = 10,
    ) {
        self.samplesPerPixel = samplesPerPixel
        self.maxDepth = maxDepth
        
        self.pixelSamplesScale = 1.0 / Double(samplesPerPixel)
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
    
    // MARK: Rendering
    
    let bucketSize = 64
    let workersPerBucket = 1
    
    func render(
        camera: Camera,
        world: any Hittable
    ) {
        parallelism ? renderMultithreaded(camera: camera, world: world) : renderSingleThread(camera: camera, world: world)
    }
    
    private func renderSingleThread(camera: Camera, world: any Hittable) {
        let standardError = FileHandle.standardError
        let width = camera.imageWidth
        let height = camera.imageHeight
        print("P3\n\(width) \(height)\n255")
        for j in 0..<height{
            let message = "\rScanlines remaining: \(height - j) \n"
            standardError.write(message.data(using: .utf8)!)
            for i in 0..<width{
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
    private func renderMultithreaded(camera: Camera, world: any Hittable) {
        // data will be written in a buffer
        // in terms of parallelism i have found that the main options are bucket and progressive rendering
        // i'll go for a hybrid approach and maybe allow some configurations (render bucket size, refresh rate) later on
        //      1. split the image into equal-sized render buckets (64x64) and have a separate thread for each tile
        //      2. don't take all samples per pixel in one go (go by 10 sample increments)
        // note that Swift's RandomNumberGenerator is both thread safe and each thread has a different seed (automatically)
        
        let height = camera.imageHeight
        let width = camera.imageWidth
        let horizontalBuckets = Int(ceil(Double(width) / Double(bucketSize)))
        let verticalBuckets = Int(ceil(Double(height) / Double(bucketSize)))
        
        let bucketsGroup = DispatchGroup()
        let bucketsQueue = DispatchQueue.global(qos: .userInitiated)
        let renderBuffer = RenderBuffer(size: width * height)
        
        
        let standardError = FileHandle.standardError
        
        let iterations = (samplesPerPixel + 10) / 10
        for iteration in 0..<iterations {
            standardError.write("\rRemaining samples: \(iterations - iteration) \n".data(using: .utf8)!)
            for x in 0..<horizontalBuckets { //TODO: handle errors
                for y in 0..<verticalBuckets {
                    bucketsGroup.enter()
                    bucketsQueue.async {
                        renderBucket(
                            camera: camera,
                            world: world,
                            leftCornerX: x * self.bucketSize,
                            leftCornerY: y * self.bucketSize,
                            renderBuffer: renderBuffer,
                            sampleCount: (iteration == iterations - 1) ? iterations % 10 : 10
                        )
                        bucketsGroup.leave( )
                    }
                }
            }
            bucketsGroup.wait()
        }
        
        print("P3\n\(width) \(height)\n255")
        for pixel in renderBuffer.pixels {
            writeColor(pixelColor: pixel * pixelSamplesScale)
        }
        standardError.write("\rDone.\n".data(using: .utf8)!)
    }
    private func renderBucket(
        camera: Camera,
        world: any Hittable,
        leftCornerX: Int,
        leftCornerY: Int,
        renderBuffer: RenderBuffer,
        sampleCount: Int
    ) {
        
        let iMax = min(leftCornerX + bucketSize, camera.imageWidth)
        let jMax = min(leftCornerY + bucketSize, camera.imageHeight)
        
        //let standardError = FileHandle.standardError
        //standardError.write("\rEntering bucket \(leftCornerX) \(leftCornerY) \n".data(using: .utf8)!)
        for j in leftCornerY..<jMax{
            for i in leftCornerX..<iMax{
                let currentPixel = j * camera.imageWidth + i
                for _ in 0..<sampleCount{
                    let ray = camera.getRay(i, j)
                    renderBuffer.pixels[currentPixel] += rayColor(r: ray, depth: maxDepth, world: world)
                }
            }
        }
        //standardError.write("\rBucket \(leftCornerX) \(leftCornerY) complete \n".data(using: .utf8)!)
    }
}
