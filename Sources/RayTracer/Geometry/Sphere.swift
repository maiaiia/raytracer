import Foundation
struct Sphere: Hittable {
    private var _center: Point3
    private var _radius: Double
    
    init(center: Point3, radius: Double) {
        _center = center
        _radius = radius
    }
    
    func hit(r: Ray, rayTMin: Double, rayTMax: Double) -> HitRecord? {
        let OC = _center - r.origin()
        let a = r.direction().length_squared
        let h = r.direction().dot(OC)
        let c = OC.length_squared - _radius * _radius
        
        let delta = h * h - a * c
        if delta < 0 {
            return nil
        }
        
        let sqrtd = sqrt(delta)
        var root = (h - sqrtd) / a
        if root <= rayTMin || root >= rayTMax {
            root = (h + sqrtd) / a
            if root <= rayTMin || root >= rayTMax {
                return nil
            }
        }
        return HitRecord(t: root,
                         p: r.at(t: root),
                         r: r,
                         outwardNormal: (r.at(t: root) - _center) / _radius)
    }
}
