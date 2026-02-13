import Foundation
struct Sphere: Hittable {
    private var _center:    Point3
    private var _radius:    Double
    private var _material:  any Material
    
    init(center: Point3, radius: Double, material: Material) {
        _center = center
        _radius = radius > 0 ? radius : 0
        _material = material
    }
    
    func hit(r: Ray, rayT: Interval) -> HitRecord? {
        let OC = _center - r.origin()
        let a = r.direction().lengthSquared
        let h = r.direction().dot(OC)
        let c = OC.lengthSquared - _radius * _radius
        
        let delta = h * h - a * c
        if delta < 0 {
            return nil
        }
        
        let sqrtd = sqrt(delta)
        var root = (h - sqrtd) / a
        if !rayT.surrounds(root) {
            root = (h + sqrtd) / a
            if !rayT.surrounds(root) {
                return nil
            }
        }
        return HitRecord(t: root,
                         p: r.at(t: root),
                         r: r,
                         outwardNormal: (r.at(t: root) - _center) / _radius,
                         material: _material
        )
    }
}
