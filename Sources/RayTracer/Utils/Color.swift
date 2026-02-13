import Foundation
typealias Color = Vec3

let intensity = Interval(0.0, 0.999)

//TODO: maybe redirect to a different output stream if needed later on
func writeColor(pixelColor: Color) -> Void {
    let r = linearToGamma(pixelColor.x)
    let g = linearToGamma(pixelColor.y)
    let b = linearToGamma(pixelColor.z)
    
    let rByte = Int(256 * intensity.clamp(r))
    let gByte = Int(256 * intensity.clamp(g))
    let bByte = Int(256 * intensity.clamp(b))
    
    print("\(rByte) \(gByte) \(bByte)")
}

func linearToGamma(_ linearComponent: Double) -> Double {
    return linearComponent > 0 ? sqrt(linearComponent) : 0.0
}
