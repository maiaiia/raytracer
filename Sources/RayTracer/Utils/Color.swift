import Foundation
typealias Color = Vec3

//TODO: maybe redirect to a different output stream if needed later on
func writeColor(pixelColor: Color) -> Void {
    let r = pixelColor.x
    let g = pixelColor.y
    let b = pixelColor.z
    print("\(Int(r * 255.999)) \(Int(g * 255.999)) \(Int(b * 255.999))")
}
