import Foundation
struct Camera {
    private var imageHeight: Int            // final image height
    private var cameraCenter: Point3        // camera center
    private var pixel00: Point3             // location of pixel 0, 0
    private var pixelDX: Vec3               // offset to pixel to the right
    private var pixelDY: Vec3               // offset to pixel below
    private var pixelSamplesScale: Double
    
    var aspectRatio = 1.0
    var imageWidth = 100
    var samplesPerPixel = 10
    
    init(aspectRatio: Double = 1.0, imageWidth: Int = 100, samplesPerPixel: Int = 10) {
        self.aspectRatio = aspectRatio
        self.imageWidth = imageWidth
        
        imageHeight = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
        cameraCenter = Point3(0,0,0)
        pixelSamplesScale = 1.0 / Double(samplesPerPixel)
        
        //Viewport info
        //  dimensions
        let focalLength: Double = 1.0
        let viewportHeight: Double = 2.0
        let viewportWidth: Double = viewportHeight * (Double(imageWidth) / Double (imageHeight))
        
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
                    pixelColor += self.rayColor(r: ray, world: world)
                }
                writeColor(pixelColor: pixelColor * pixelSamplesScale)
            }
        }
        standardError.write("\rDone.\n".data(using: .utf8)!)
    }
    
    private func rayColor(r: Ray, world: any Hittable) -> Color {
        if let record = world.hit(r: r, rayT: Interval(0.0001, Double.infinity)) {
            return 0.5 * (record.normal + Color(1.0, 1.0, 1.0))
        }
        
        // gradient background
        let unitDirection = r.direction().normalized
        let a: Double = 0.5 * (unitDirection.y + 1.0) // lerp
        return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0)
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
