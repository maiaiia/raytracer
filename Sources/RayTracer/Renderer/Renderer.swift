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
    
    let bucketSize = 64
    let workersPerBucket = 1
    
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
        
        let renderBuffer = RenderBuffer(size: width * height)
        var rng = SystemRandomNumberGenerator()
        
        for j in 0..<height{
            let message = "\rScanlines remaining: \(height - j) \n"
            standardError.write(message.data(using: .utf8)!)
            for i in 0..<width{
                let currentPixel = j * camera.imageWidth + i
                for _ in 0..<samplesPerPixel{
                    let ray = camera.getRay(i, j, rng: &rng)
                    renderBuffer.pixels[currentPixel] += rayColor(r: ray, depth: maxDepth, world: world, rng: &rng)
                }
            }
        }
        
        //Renderer.writePPM(width: width, height: height, renderBuffer: renderBuffer, sampleCount: samplesPerPixel)
        standardError.write("\rDone.\n".data(using: .utf8)!)
        
    }
    private func renderMultithreaded(camera: Camera, world: any Hittable) {
        /*
        data will be written in a buffer
        in terms of parallelism i have found that the main options are bucket and progressive rendering
        progressive rendering has actually slowed things down for me so i'll go for bucket rendering only (for now)
         */
        
        let height = camera.imageHeight
        let width = camera.imageWidth
        let horizontalBuckets = Int(ceil(Double(width) / Double(bucketSize)))
        let verticalBuckets = Int(ceil(Double(height) / Double(bucketSize)))
        
        let bucketsGroup = DispatchGroup()
        let bucketsQueue = DispatchQueue.global(qos: .userInitiated)
        let renderBuffer = RenderBuffer(size: width * height)
        
        let standardError = FileHandle.standardError
        
        //standardError.write("\rRemaining samples: \(iterations - iteration - 1) \n".data(using: .utf8)!)
        for x in 0..<horizontalBuckets { //TODO: handle errors
            for y in 0..<verticalBuckets {
                bucketsGroup.enter()
                bucketsQueue.async {
                    var rng = SystemRandomNumberGenerator()
                    renderBucket(
                        camera: camera,
                        world: world,
                        leftCornerX: x * self.bucketSize,
                        leftCornerY: y * self.bucketSize,
                        renderBuffer: renderBuffer,
                        sampleCount: samplesPerPixel,
                        rng: &rng
                    )
                    bucketsGroup.leave()
                    // TODO: This is where I'd update the display
                }
            }
        }
        bucketsGroup.wait()
        
        Renderer.writePPM(width: width, height: height, renderBuffer: renderBuffer, sampleCount: samplesPerPixel)
        standardError.write("\rDone.\n".data(using: .utf8)!)
    }
    private func renderBucket<R: RandomNumberGenerator>(
        camera: Camera,
        world: any Hittable,
        leftCornerX: Int,
        leftCornerY: Int,
        renderBuffer: RenderBuffer,
        sampleCount: Int,
        rng: inout R
    ) {
        
        let iMax = min(leftCornerX + bucketSize, camera.imageWidth)
        let jMax = min(leftCornerY + bucketSize, camera.imageHeight)
        
        let localBuffer = RenderBuffer(size: bucketSize * bucketSize)
        
        //let standardError = FileHandle.standardError
        //standardError.write("\rEntering bucket \(leftCornerX) \(leftCornerY) \n".data(using: .utf8)!)
        for j in leftCornerY..<jMax{
            for i in leftCornerX..<iMax{
                //let currentPixel = j * camera.imageWidth + i
                let localPixel = (j - leftCornerY) * bucketSize + (i - leftCornerX)
                for _ in 0..<sampleCount{
                    let ray = camera.getRay(i, j, rng: &rng)
                    localBuffer.pixels[localPixel] += rayColor(r: ray, depth: maxDepth, world: world, rng: &rng)
                }
            }
        }
        
        for j in leftCornerY..<jMax {
            for i in leftCornerX..<iMax {
                let currentPixel = j * camera.imageWidth + i
                let localPixel = (j - leftCornerY) * bucketSize + (i - leftCornerX)
                renderBuffer.pixels[currentPixel] = localBuffer.pixels[localPixel]
            }
        }
        
        //standardError.write("\rBucket \(leftCornerX) \(leftCornerY) complete \n".data(using: .utf8)!)
    }
    
    static private func writePPM(
        width: Int,
        height: Int,
        renderBuffer: RenderBuffer,
        sampleCount: Int
    ) {
        let scale = 1.0 / Double(sampleCount)
        print("P3\n\(width) \(height)\n255")
        for pixel in renderBuffer.pixels {
            writeColor(pixelColor: pixel * scale)
        }
    }
}
