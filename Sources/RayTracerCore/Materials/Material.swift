public protocol Material {
    func scatter<R: RandomNumberGenerator>(ray: Ray, rec: HitRecord, rng: inout R) -> (attenuation: Vec3, scattered: Ray)?
}
