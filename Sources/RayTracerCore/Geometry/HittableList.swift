import Foundation
public struct HittableList: Hittable {
    var objects: [any Hittable] = []
    
    public init() {}
    
    public mutating func clear() { objects.removeAll() }
    public mutating func add(_ object: any Hittable) { objects.append(object) }
    
    public func hit(r: Ray, rayT: Interval) -> HitRecord? {
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
