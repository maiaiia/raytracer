public struct Lambertian: Material {
    private var _albedo: Color
    
    public init(albedo: Color) {
        _albedo = albedo
    }
    
    public func scatter<R>(ray: Ray, rec: HitRecord, rng: inout R) -> (attenuation: Vec3, scattered: Ray)? where R : RandomNumberGenerator{
        // strategy - always scatter
        let randVec = Vec3.randomUnitVector(rng: &rng)
        let scatterDirection = (rec.normal + randVec).nearZero ? rec.normal : rec.normal + randVec
        
        let scattered = Ray(origin: rec.p, direction: scatterDirection)
        let attenuation = _albedo
        return (attenuation, scattered)
        
        //other options:
        //  if reflectance is R, scatter with probability (1 - R) and absorb everything not scattered (no attenuation)
        //  scatter with fixed probability p and attenuate with albedo / p
    }
    
}
