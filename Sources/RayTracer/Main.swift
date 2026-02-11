import Foundation

func hitSphere(center: Point3, radius: Double, r: Ray) -> Double{
    let OC = center - r.origin()
    let a = r.direction().dot(r.direction())
    let b = -2 * r.direction().dot(OC)
    let c = OC.dot(OC) - radius * radius
    let delta = b * b - 4 * a * c
    if delta < 0 {
        return -1.0 //not hit
    } else {
        return ( -b - sqrt(delta)) / (2.0 * a) // normal
    }
}

func rayColor(r: Ray) -> Color {
    let t = hitSphere(center: Point3(0, 0, -1), radius: 0.5, r: r)
    if t > 0.0 {
        let normalVector = (r.at(t: t) - Point3(0, 0, -1)).normalized // so each component is in the range [-1, 1]
        return 0.5 * Color(normalVector.x + 1, normalVector.y + 1, normalVector.z + 1)
        // add 1 to each component to shift the values to [0, 2]. halve to map values to [0, 1]
    }
    
    let unitDirection = r.direction().normalized
    let a: Double = 0.5 * (unitDirection.y + 1.0) // lerp
    return (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0)
}

func main() {
    // Image
    let aspectRatio: Double = 16.0 / 9.0
    let imageWidth: Int = 400
    let imageHeight: Int = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
    
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
            
            let pixelColor = rayColor(r: ray)
            writeColor(pixelColor: pixelColor)
        }
    }
    standardError.write("\rDone.\n".data(using: .utf8)!)
}

main()
