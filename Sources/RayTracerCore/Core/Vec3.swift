import Foundation
public struct Vec3 {
    var x: Double
    var y: Double
    var z: Double
    
    public init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    subscript(i: Int) -> Double {
        get {
            precondition(i >= 0 && i < 3, "index out of range")
            switch i {
            case 0: return x
            case 1: return y
            case 2: return z
            default: fatalError("invalid index")
            }
        }
        set {
            precondition(i >= 0 && i < 3, "index out of range")
            switch i {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: fatalError("invalid index")
            }
        }
    }
    
    // MARK: Properties
    public var length: Double {
        return sqrt(lengthSquared)
    }
    public var lengthSquared: Double {
        return x*x + y*y + z*z
    }
    public var normalized: Vec3 {
        return self / length
    }
    public var nearZero: Bool {
        let eps = 1e-8
        return abs(x) < eps && abs(y) < eps && abs(z) < eps
    }
    
}

// MARK: Operations with Vectors
public extension Vec3 {
    func dot(_ other: Vec3) -> Double {
        return x * other.x + y * other.y + z * other.z
    }
    func cross(_ other: Vec3) -> Vec3 {
        let newX = y * other.z - z * other.y
        let newY = z * other.x - x * other.z
        let newZ = x * other.y - y * other.x
        return Vec3(newX, newY, newZ)
    }
    func hadamard(_ other: Vec3) -> Vec3 {
        return Vec3(x * other.x, y * other.y, z * other.z)
    }
}

// MARK: Operators
public extension Vec3 {
    static prefix func - (v: Vec3) -> Vec3 {
        return Vec3(-v.x, -v.y, -v.z)
    }
}

public extension Vec3 {
    static func + (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return Vec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    static func - (lhs: Vec3, rhs: Vec3) -> Vec3 {
        return lhs + -rhs
    }
    static func * (lhs: Vec3, rhs: Double) -> Vec3 {
        return Vec3(lhs.x * rhs, lhs.y * rhs, lhs.z * rhs)
    }
    static func * (lhs: Double, rhs: Vec3) -> Vec3 {
        return rhs * lhs
    }
    static func * (lhs: Vec3, rhs: Int) -> Vec3 {
        return lhs * Double(rhs)
    }
    static func * (lhs: Int, rhs: Vec3) -> Vec3 {
        return Double(lhs) * rhs
    }
    static func / (lhs: Vec3, rhs: Double) -> Vec3 {
        return lhs * (1.0 / rhs)
    }
    static func / (lhs: Vec3, rhs: Int) -> Vec3 {
        return lhs / Double(rhs)
    }
    
    static func += (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs + rhs
    }
    static func -= (lhs: inout Vec3, rhs: Vec3) {
        lhs = lhs - rhs
    }
    static func *= (lhs: inout Vec3, rhs: Double) {
        lhs = lhs * rhs
    }
    static func *= (lhs: inout Vec3, rhs: Int) {
        lhs = lhs * rhs
    }
    static func /= (lhs: inout Vec3, rhs: Double) {
        lhs = lhs / rhs
    }
    static func /= (lhs: inout Vec3, rhs: Int) {
        lhs = lhs / rhs
    }
}

// MARK: Protocols
extension Vec3: CustomStringConvertible {
    public var description: String {
        "\(x) \(y) \(z)"
    }
}
extension Vec3: Equatable {
    public static func == (lhs: Vec3, rhs: Vec3) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

// MARK: Random utility functions
extension Vec3 {
    public static func random() -> Vec3 {
        return Vec3(randomDouble(), randomDouble(), randomDouble())
    }
    static func random(min: Double, max: Double) -> Vec3 {
        return Vec3(randomDouble(min: min, max: max), randomDouble(min: min, max: max), randomDouble(min: min, max: max))
    }
    static func random<R>(min: Double, max: Double, rng: inout R) -> Vec3 where R : RandomNumberGenerator {
        return Vec3(randomDouble(min: min, max: max, rng: &rng),
                    randomDouble(min: min, max: max, rng: &rng),
                    randomDouble(min: min, max: max, rng: &rng))
    }
    
    static func randomUnitVector() -> Vec3 {
        // generate a random unit vector using a rejection method
        while true{
            let p = Vec3.random(min: -1, max: 1)
            if p.lengthSquared <= 1.0 && 1e-160 < p.lengthSquared{
                return p.normalized
            }
        }
    }
    static func randomUnitVector<R>(rng: inout R) -> Vec3 where R : RandomNumberGenerator{
        while true{
            let p = Vec3.random(min: -1, max: 1, rng: &rng)
            if p.lengthSquared <= 1.0 && 1e-160 < p.lengthSquared{
                return p.normalized
            }
        }
    }
    static func randomOnHemisphere (normal: Vec3) -> Vec3 {
        let onUnitSphere = randomUnitVector()
        if onUnitSphere.dot(randomUnitVector()) > 0.0 { 
            return onUnitSphere
        } else {
            return -onUnitSphere
        }
    }
    static func randomOnHemisphere<R>(normal: Vec3, rng: inout R) -> Vec3 where R : RandomNumberGenerator{
        let onUnitSphere = randomUnitVector(rng: &rng)
        if onUnitSphere.dot(randomUnitVector(rng: &rng)) > 0.0 {
            return onUnitSphere
        } else {
            return -onUnitSphere
        }
    }
    static func randomInUnitDisk() -> Vec3 {
        while true {
            let p = Vec3(randomDouble(min: -1, max: 1), randomDouble(min: -1, max: 1), 0)
            if p.lengthSquared < 1 { return p }
        }
    }
    static func randomInUnitDisk<R>(rng: inout R) -> Vec3 where R : RandomNumberGenerator{
        while true {
            let p = Vec3(randomDouble(min: -1, max: 1, rng: &rng), randomDouble(min: -1, max: 1, rng: &rng), 0)
            if p.lengthSquared < 1 { return p }
        }
    }
}

// MARK: Geometry
extension Vec3 {
    func reflect(relativeTo normal: Vec3) -> Vec3 {
        self - 2 * self.dot(normal) * normal
    }
    func refract(normal: Vec3, etaRatio: Double) -> Vec3 {
        // etaRatio = etaIncident / etaTransmitted
        
        // the refracted ray is decomposed into its perpendicular and parallel components to ease computations
        let cosTheta = min(-self.dot(normal), 1.0)
        let outRayPerpendicular = etaRatio * (self + cosTheta * normal)
        let outRayParallel = -sqrt(abs(1.0 - outRayPerpendicular.lengthSquared)) * normal
        return outRayParallel + outRayPerpendicular
    }
}

public typealias Point3 = Vec3
