import Foundation
struct HittableList: Hittable {
    var objects: [any Hittable] = []
    
    mutating func clear() { objects.removeAll() }
    mutating func add(_ object: any Hittable) { objects.append(object) }
    
    func hit(r: Ray, rayT: Interval) -> HitRecord? {
        var record: HitRecord? = nil
        var closestSoFar = rayT.right
        
        for object in objects {
            if let tempRecord = object.hit(r: r, rayT: Interval(rayT.left, closestSoFar)) {
                closestSoFar = tempRecord.t
                record = tempRecord
            }
        }
        
        return record
    }
}
