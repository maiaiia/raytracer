import Foundation

func rayColor(r: Ray, world: any Hittable) -> Color {
    // hit objects
    if let record = world.hit(r: r, rayT: Interval(0.0001, Double.infinity)) {
        return 0.5 * (record.normal + Color(1.0, 1.0, 1.0))
    }
    
    // gradient background
    let unitDirection = r.direction().normalized
    let a: Double = 0.5 * (unitDirection.y + 1.0) // lerp
    return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0)
}

func main() {
    // Image
    let aspectRatio: Double = 16.0 / 9.0
    let imageWidth: Int = 400
    let imageHeight: Int = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
    
    // World
    var world: HittableList = HittableList()
    world.add(Sphere(center: Point3(0, 0, -1), radius: 0.5))
    world.add(Sphere(center: Point3(1.5, 0, -1), radius: 0.5))
    
    // Camera
    let focalLength: Double = 1.0
    let viewportHeight: Double = 2.0
    let viewportWidth: Double = viewportHeight * (Double(imageWidth) / Double (imageHeight))
    let cameraCenter = Point3(0,0,0)
    
    //Viewport info
    //  rendering direction
    let u = Vec3(viewportWidth, 0, 0)
    let v = Vec3(0, -viewportHeight, 0)
    //  distance between pixels
    let deltaU = u / imageWidth
    let deltaV = v / imageHeight
    //  upper left pixel
    let viewportUpperLeft = cameraCenter - Vec3(0,0,focalLength) - 0.5 * (u + v)
    let pixel00 = viewportUpperLeft + 0.5 * (deltaU + deltaV)
    
    // Render
    let standardError = FileHandle.standardError
    print("P3\n\(imageWidth) \(imageHeight)\n255")
    for j in 0...imageHeight-1{
        let message = "\rScanlines remaining: \(imageHeight - j) \n"
        standardError.write(message.data(using: .utf8)!)
        for i in 0...imageWidth-1{
            let pixelCenter = pixel00 + (i * deltaU) + (j * deltaV)
            let rayDirection = pixelCenter - cameraCenter
            let ray = Ray(origin: cameraCenter, direction: rayDirection)
            
            let pixelColor = rayColor(r: ray, world: world)
            writeColor(pixelColor: pixelColor)
        }
    }
    standardError.write("\rDone.\n".data(using: .utf8)!)
}

main()
