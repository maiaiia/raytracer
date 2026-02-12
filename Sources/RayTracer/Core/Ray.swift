import Foundation

struct Ray {
    private var _origin: Point3
    private var _direction: Vec3
    
    init(origin: Point3, direction: Vec3) {
        self._origin = origin
        self._direction = direction
    }
    
    func origin() -> Point3 {
        _origin
    }
    func direction() -> Vec3 {
        _direction
    }
    func at(t: Double) -> Point3 {
        _origin + _direction * t
    }
    
}
