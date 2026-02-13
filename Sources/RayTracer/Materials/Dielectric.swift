import Foundation
struct Dielectric : Material {
    private var _refractionIndex: Double
    init(refractionIndex: Double) {
        self._refractionIndex = refractionIndex
    }
    
    func scatter(ray: Ray, rec: HitRecord) -> (attenuation: Vec3, scattered: Ray)? {
        let attenuation = Color(1.0, 1.0, 1.0) // for glass
        let refractionIndex = rec.frontFace ? 1.0 / self._refractionIndex : self._refractionIndex
        
        let unitDirection = ray.direction().normalized
        
        // Check if the ray gets reflected or refracted
        let cosTheta = min(1.0, -unitDirection.dot(rec.normal))
        let sinTheta = sqrt(1.0 - cosTheta * cosTheta)
        
        let direction = refractionIndex * sinTheta > 1.0 ? unitDirection.reflect(relativeTo: rec.normal) : unitDirection.refract(normal: rec.normal, etaRatio: refractionIndex)
        
        let scattered = Ray(origin: rec.p, direction: direction)
        return (attenuation, scattered)
    }
}
