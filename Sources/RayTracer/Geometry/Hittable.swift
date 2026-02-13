//design decision
//  normals always point outward from the surface
//  thus, the side of the surface will be determined at the time of geometry intersection
struct HitRecord {
    var p:          Point3
    var normal:     Vec3
    var t:          Double
    var material:   any Material
    
    init(t: Double, p: Point3, r: Ray, outwardNormal: Vec3, material: any Material) {
        self.t = t
        self.p = p
        
        // set face normal
        let frontFace: Bool = r.direction().dot(outwardNormal) < 0
        self.normal = frontFace ? outwardNormal : -outwardNormal
        self.material = material
    }
    
}

protocol Hittable {
    func hit(r: Ray, rayT: Interval) -> HitRecord?
}
