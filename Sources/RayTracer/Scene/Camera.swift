import Foundation
struct Camera {
    // MARK: public cofiguration
    var aspectRatio     = 1.0
    var imageWidth      = 100
    var samplesPerPixel = 10    // count of random samples per pixel
    var maxDepth        = 10    // maximum number of ray bounces into scene
    
    var vfov        = 90                // vertical view angle (field of view)
    var lookFrom    = Point3(0, 0, 0)   // position of camera lens
    var lookAt      = Point3(0, 0, -1)  // point camera is looking at
    var vUp         = Vec3(0, 1, 0)     // camera-relative "up" direction
    
    // MARK: private properties
    private var imageHeight:        Int         // final image height
    private var cameraCenter:       Point3      // camera center
    private var pixel00:            Point3      // location of pixel 0, 0
    private var pixelDX:            Vec3        // offset to pixel to the right
    private var pixelDY:            Vec3        // offset to pixel below
    private var pixelSamplesScale:  Double
    private var u, v, w:            Vec3        // camera frame basis vectors
    
    // MARK: computed properties
    var focalLength: Double {
        (lookFrom - lookAt).length
    }
    
    // MARK: initialisation
    init(
        aspectRatio: Double = 1.0,
        imageWidth: Int = 100,
        samplesPerPixel: Int = 10,
        maxDepth: Int = 10,
        vfov: Int = 90,
        lookFrom: Point3 = Point3(0, 0, 0),
        lookAt: Point3 = Point3(0, 0, -1),
        vUp: Vec3 = Vec3(0, 1, 0)
    ) {
        self.aspectRatio = aspectRatio
        self.imageWidth = imageWidth
        self.samplesPerPixel = samplesPerPixel
        self.maxDepth = maxDepth
        self.vfov = vfov
        self.lookFrom = lookFrom
        self.lookAt = lookAt
        self.vUp = vUp
        
        // calculate derived values
        cameraCenter = lookFrom
        imageHeight = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
        pixelSamplesScale = 1.0 / Double(samplesPerPixel)
        
        // set temporary values for uninitialised properties
        u = Vec3(0, 0, 0)
        v = Vec3(0, 0, 0)
        w = Vec3(0, 0, 0)
        pixel00 = Point3(0, 0, 0)
        pixelDY = Point3(0, 0, 0)
        pixelDX = Point3(0, 0, 0)
        
        setupViewport()
    }
    
    // MARK: Setup
    private mutating func setupViewport() {
        // viewport dimensions
        let focalLength = (lookFrom - lookAt).length
        let theta = degreesToRadians(Double(vfov))
        let h = tan(theta / 2)
        let viewportHeight = 2 * h * focalLength
        let viewportWidth = viewportHeight * (Double(imageWidth) / Double (imageHeight))
        
        // camera basis vectors
        w = (lookFrom - lookAt).normalized //TODO: - make sure w and vUp are not parallel!!
        u = vUp.cross(w).normalized
        v = w.cross(u)
        
        // viewport edge vectors
        let viewportU = viewportWidth * u
        let viewportV = viewportHeight * -v
        
        // distance between pixels
        pixelDX = viewportU / imageWidth
        pixelDY = viewportV / imageHeight
        
        // upper left pixel
        let viewportUpperLeft = cameraCenter - (focalLength * w) - 0.5 * (viewportU + viewportV)
        pixel00 = viewportUpperLeft + 0.5 * (pixelDX + pixelDY)
    }
    
    // MARK: Rendering
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
    
    // MARK: Ray tracing
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
        // random point in the [-.5, -.5] - [.5, .5] square
        return Vec3(randomDouble() - 0.5, randomDouble() - 0.5, 0)
    }
}
