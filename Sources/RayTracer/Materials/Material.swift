protocol Material {
    func scatter(ray: Ray, rec: HitRecord) -> (attenuation: Vec3, scattered: Ray)?
}
