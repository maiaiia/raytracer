struct Lambertian: Material {
    private var _albedo: Color
    
    init(albedo: Color) {
        _albedo = albedo
    }
    
    func scatter(ray: Ray, rec: HitRecord) -> (attenuation: Vec3, scattered: Ray)? {
        // strategy - always scatter
        let randVec = Vec3.randomUnitVector()
        let scatterDirection = (rec.normal + randVec).nearZero ? rec.normal : rec.normal + randVec
        
        let scattered = Ray(origin: rec.p, direction: scatterDirection)
        let attenuation = _albedo
        return (attenuation, scattered)
        
        //other options:
        //  if reflectance is R, scatter with probability (1 - R) and absorb everything not scattered (no attenuation)
        //  scatter with fixed probability p and attenuate with albedo / p
    }
    
}
