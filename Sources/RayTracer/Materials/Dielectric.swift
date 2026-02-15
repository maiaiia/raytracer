import Foundation
struct Dielectric : Material {
    private var _refractiveIndex: Double
    init(refractiveIndex: Double) {
        self._refractiveIndex = refractiveIndex
    }
    
    func scatter<R>(ray: Ray, rec: HitRecord, rng: inout R) -> (attenuation: Vec3, scattered: Ray)? where R: RandomNumberGenerator{
        let attenuation = Color(1.0, 1.0, 1.0) // for glass
        let refractionIndex = rec.frontFace ? 1.0 / self._refractiveIndex : self._refractiveIndex
        
        let unitDirection = ray.direction().normalized
        
        // Check if the ray gets reflected or refracted
        let cosTheta = min(1.0, -unitDirection.dot(rec.normal))
        let sinTheta = sqrt(1.0 - cosTheta * cosTheta)
         
        let cannotRefract: Bool = refractionIndex * sinTheta > 1.0
        
        let direction = (cannotRefract && Dielectric.reflectance(cosine: cosTheta, refractiveIndex: refractionIndex) > randomDouble(rng: &rng)) ? unitDirection.reflect(relativeTo: rec.normal) : unitDirection.refract(normal: rec.normal, etaRatio: refractionIndex)
        
        let scattered = Ray(origin: rec.p, direction: direction)
        return (attenuation, scattered)
    }
    
    static private func reflectance(cosine: Double, refractiveIndex: Double) -> Double {
        // Schlick's approximation for reflectance
        var r = (1 - refractiveIndex) / (1 + refractiveIndex)
        r = r * r
        return r + (1 - r) * pow(1.0 - cosine, 5.0)
    }
}
