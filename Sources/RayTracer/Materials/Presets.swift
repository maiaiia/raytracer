extension Dielectric {
    static let glass = Dielectric(refractiveIndex: 1.5)
    static let water = Dielectric(refractiveIndex: 1.333)
    static let diamond = Dielectric(refractiveIndex: 2.417)
    static let airBubble = Dielectric(refractiveIndex: 1.00 / 1.333)
}

extension Metal {
    static let gold = Metal(albedo: Color(1.0, 0.776, 0.336), fuzz: 0.3)
    static let silver = Metal(albedo: Color(0.753, 0.753, 0.753), fuzz: 0.1)
    static let copper = Metal(albedo: Color(0.955, 0.638, 0.538), fuzz: 0.2)
}

extension Lambertian {
    
}
