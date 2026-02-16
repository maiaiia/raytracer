import Foundation
func degreesToRadians(_ degrees: Double) -> Double {
    return degrees * Double.pi / 180.0
}
func randomDouble() -> Double {
    return Double.random(in: 0.0..<1.0)
}
func randomDouble<R: RandomNumberGenerator>(rng: inout R) -> Double {
    return Double.random(in: 0.0..<1.0, using: &rng)
}
func randomDouble(min: Double, max: Double) -> Double{
    return min + (max - min) * randomDouble()
}
func randomDouble<R: RandomNumberGenerator>(min: Double, max: Double, rng: inout R) -> Double {
    return min + (max - min) * randomDouble(rng: &rng)
}
