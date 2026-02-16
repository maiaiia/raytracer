public struct Metal: Material {
    
    private var _albedo: Color
    private var _fuzz: Double
    public init(albedo: Color, fuzz: Double = 0.0) {
        self._albedo = albedo
        self._fuzz = fuzz < 1 ? fuzz : 1
    }
    
    public func scatter<R>(ray: Ray, rec: HitRecord, rng: inout R) -> (attenuation: Vec3, scattered: Ray)? where R : RandomNumberGenerator{
        let reflected = (ray.direction().reflect(relativeTo: rec.normal)).normalized + _fuzz * Vec3.randomUnitVector(rng: &rng)
        let scattered = Ray(origin: rec.p, direction: reflected)
        let attenuation = _albedo
        if scattered.direction().dot(rec.normal * _fuzz) <= 0 { return nil }
        return (attenuation, scattered)
    }
    
}
