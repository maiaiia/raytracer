import Foundation
struct HittableList: Hittable {
    var objects: [any Hittable] = []
    
    mutating func clear() { objects.removeAll() }
    mutating func add(_ object: any Hittable) { objects.append(object) }
    
    func hit(r: Ray, rayTMin: Double, rayTMax: Double) -> HitRecord? {
        var record: HitRecord? = nil
        var closestSoFar = rayTMax
        
        for object in objects {
            if let tempRecord = object.hit(r: r, rayTMin: rayTMin, rayTMax: closestSoFar) {
                closestSoFar = tempRecord.t
                record = tempRecord
            }
        }
        
        return record
    }
}
