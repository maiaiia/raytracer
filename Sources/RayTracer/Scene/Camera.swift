import Foundation
struct Camera {
    private var imageHeight:        Int         // final image height
    private var cameraCenter:       Point3      // camera center
    private var pixel00:            Point3      // location of pixel 0, 0
    private var pixelDX:            Vec3        // offset to pixel to the right
    private var pixelDY:            Vec3        // offset to pixel below
    private var pixelSamplesScale:  Double
    
    var aspectRatio     = 1.0
    var imageWidth      = 100
    var samplesPerPixel = 10    // count of random samples per pixel
    var maxDepth        = 10    // maximum number of ray bounces into scene
    var vfov            = 90    // vertical view angle (field of view)
    
    init(aspectRatio: Double = 1.0, imageWidth: Int = 100, samplesPerPixel: Int = 10, maxDepth: Int = 10, vfov: Int = 90) {
        self.aspectRatio = aspectRatio
        self.imageWidth = imageWidth
        self.samplesPerPixel = samplesPerPixel
        self.maxDepth = maxDepth
        self.vfov = vfov
        
        imageHeight = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
        cameraCenter = Point3(0,0,0)
        pixelSamplesScale = 1.0 / Double(samplesPerPixel)
        
        //Viewport info
        //  dimensions
        let focalLength = 1.0
        let theta = degreesToRadians(Double(vfov))
        let h = tan(theta / 2)
        let viewportHeight = 2 * h * focalLength
        let viewportWidth = viewportHeight * (Double(imageWidth) / Double (imageHeight))
        
        //  rendering direction
        let u = Vec3(viewportWidth, 0, 0)
        let v = Vec3(0, -viewportHeight, 0)
        //  distance between pixels
        pixelDX = u / imageWidth
        pixelDY = v / imageHeight
        //  upper left pixel
        let viewportUpperLeft = cameraCenter - Vec3(0,0,focalLength) - 0.5 * (u + v)
        pixel00 = viewportUpperLeft + 0.5 * (pixelDX + pixelDY)
    }
    
    func render(world: any Hittable) {
        //self.init()
        let standardError = FileHandle.standardError
        print("P3\n\(imageWidth) \(imageHeight)\n255")
        for j in 0...imageHeight-1{
            let message = "\rScanlines remaining: \(imageHeight - j) \n"
            standardError.write(message.data(using: .utf8)!)
            for i in 0...imageWidth-1{
                var pixelColor = Color(0, 0, 0)
                for _ in 0...samplesPerPixel{
                    let ray = self.getRay(i, j)
                    pixelColor += self.rayColor(r: ray, depth: maxDepth, world: world)
                }
                writeColor(pixelColor: pixelColor * pixelSamplesScale)
            }
        }
        standardError.write("\rDone.\n".data(using: .utf8)!)
    }
    
    private func rayColor(r: Ray, depth: Int, world: any Hittable) -> Color {
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
    
    private func getRay(_ i: Int, _ j: Int) -> Ray{
        let offset = sampleSquare()
        let pixelSample = pixel00 + (Double(i) + offset.x) * pixelDX + (Double(j) + offset.y) * pixelDY
        let rayOrigin = cameraCenter
        let rayDirection = (pixelSample - rayOrigin)//.normalized
        return Ray(origin: rayOrigin, direction: rayDirection)
    }
    private func sampleSquare() -> Vec3 {
        // the position vector of a random point in the [-.5, -.5] - [.5, .5] square
        return Vec3(randomDouble() - 0.5, randomDouble() - 0.5, 0)
    }
}
