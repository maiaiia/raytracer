//design decision
//  normals always point outward from the surface
//  thus, the side of the surface will be determined at the time of geometry intersection
public struct HitRecord {
    var p:          Point3
    var normal:     Vec3
    var t:          Double
    var material:   any Material
    var frontFace:  Bool
    
    init(t: Double, p: Point3, r: Ray, outwardNormal: Vec3, material: any Material) {
        self.t = t
        self.p = p
        
        // set face normal
        self.frontFace = r.direction().dot(outwardNormal) < 0
        self.normal = frontFace ? outwardNormal : -outwardNormal
        self.material = material
    }
    
}

public protocol Hittable { //TODO: When i create a separate World class I should make this internal again (along ray and interval)
    func hit(r: Ray, rayT: Interval) -> HitRecord?
}
