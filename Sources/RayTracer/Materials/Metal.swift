struct Metal: Material {
    private var _albedo: Color
    init(albedo: Color) {
        self._albedo = albedo
    }
    func scatter(ray: Ray, rec: HitRecord) -> (attenuation: Vec3, scattered: Ray)? {
        let reflected = ray.direction().reflect(relativeTo: rec.normal)
        let scattered = Ray(origin: rec.p, direction: reflected)
        let attenuation = _albedo
        return (attenuation, scattered)
    }
    
}
