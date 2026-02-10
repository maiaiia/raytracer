import Foundation
struct Vec3 {
    var x: Double
    var y: Double
    var z: Double
    
    init(_ x: Double = 0, _ y: Double = 0, _ z: Double = 0) {
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
    
     
    var length: Double {
        return sqrt(length_squared)
    }
    var length_squared: Double {
        return x*x + y*y + z*z
    }
    var normalized: Vec3 {
        return self / length
    }
    
    func dot(_ other: Vec3) -> Double {
        return x * other.x + y * other.y + z * other.z
    }
    func cross(_ other: Vec3) -> Vec3 {
        let newX = y * other.z - z * other.y
        let newY = z * other.x - x * other.z
        let newZ = x * other.y - y * other.x
        return Vec3(newX, newY, newZ)
    }
}

// MARK: Operators
extension Vec3 {
    static prefix func - (v: Vec3) -> Vec3 {
        return Vec3(-v.x, -v.y, -v.z)
    }
}

extension Vec3 {
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
    static func / (lhs: Vec3, rhs: Double) -> Vec3 {
        return lhs * (1.0 / rhs)
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
    static func /= (lhs: inout Vec3, rhs: Double) {
        lhs = lhs / rhs
    }
}

// MARK: Protocols
extension Vec3: CustomStringConvertible {
    var description: String {
        "\(x) \(y) \(z)"
    }
}
extension Vec3: Equatable {
    static func == (lhs: Vec3, rhs: Vec3) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

typealias Point3 = Vec3
