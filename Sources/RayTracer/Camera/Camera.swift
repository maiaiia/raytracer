import Foundation
struct Camera {
    // MARK: public cofiguration
    var aspectRatio     = 1.0
    var imageWidth      = 100
    var imageHeight:        Int
    
    var vfov        = 90                // vertical view angle (field of view)
    var lookFrom    = Point3(0, 0, 0)   // position of camera lens
    var lookAt      = Point3(0, 0, -1)  // point camera is looking at
    var vUp         = Vec3(0, 1, 0)     // camera-relative "up" direction
    
    var defocusAngle    = 0.0       // aperture size (0 - everything is in focus)
    var focusDistance   = 10.0      // distance from camera lookFrom to focus plane
    
    // MARK: private properties
    private var cameraCenter:       Point3      // camera center
    private var pixel00:            Point3      // location of pixel 0, 0
    private var pixelDX, pixelDY:   Vec3        // offset to pixel to the right / below
    private var u, v, w:            Vec3        // camera frame basis vectors
    private var defocusDiskU:       Vec3        // defocus disk horizontal radius
    private var defocusDiskV:       Vec3        // defocus disk vertical radius
    
    // MARK: computed properties
    var focalLength: Double {
        (lookFrom - lookAt).length
    }
    
    // MARK: initialisation
    init(
        aspectRatio: Double = 1.0,
        imageWidth: Int = 100,
        vfov: Int = 90,
        lookFrom: Point3 = Point3(0, 0, 0),
        lookAt: Point3 = Point3(0, 0, -1),
        vUp: Vec3 = Vec3(0, 1, 0),
        defocusAngle: Double = 0.0,
        focusDistance: Double = 10.0
    ) {
        self.aspectRatio = aspectRatio
        self.imageWidth = imageWidth
        self.vfov = vfov
        self.lookFrom = lookFrom
        self.lookAt = lookAt
        self.vUp = vUp
        self.defocusAngle = defocusAngle
        self.focusDistance = focusDistance
        
        // calculate derived values
        cameraCenter = lookFrom
        imageHeight = Int(Double(imageWidth) / aspectRatio) < 1 ? 1 : Int(Double(imageWidth) / aspectRatio)
        
        // set temporary values for uninitialised properties
        u = Vec3(0, 0, 0)
        v = Vec3(0, 0, 0)
        w = Vec3(0, 0, 0)
        pixel00 = Point3(0, 0, 0)
        pixelDY = Point3(0, 0, 0)
        pixelDX = Point3(0, 0, 0)
        defocusDiskU = Vec3(0, 0, 0)
        defocusDiskV = Vec3(0, 0, 0)
        setupViewport()
    }
    
    // MARK: Setup
    private mutating func setupViewport() {
        // viewport dimensions
        //let focalLength = (lookFrom - lookAt).length
        let theta = degreesToRadians(Double(vfov))
        let h = tan(theta / 2)
        let viewportHeight = 2 * h * focusDistance
        let viewportWidth = viewportHeight * (Double(imageWidth) / Double (imageHeight))
        
        // camera basis vectors
        w = (lookFrom - lookAt).normalized //TODO: - make sure w and vUp are not parallel!!
        u = vUp.cross(w).normalized
        v = w.cross(u)
        
        // viewport edge vectors
        let viewportU = viewportWidth * u
        let viewportV = viewportHeight * -v
        
        // distance between pixels
        pixelDX = viewportU / imageWidth
        pixelDY = viewportV / imageHeight
        
        // upper left pixel
        let viewportUpperLeft = cameraCenter - (focusDistance * w) - 0.5 * (viewportU + viewportV)
        pixel00 = viewportUpperLeft + 0.5 * (pixelDX + pixelDY)
        
        // camera defocus disk basis vectors
        let defocusRadius = focusDistance * tan(degreesToRadians(defocusAngle / 2))
        defocusDiskU = u * defocusRadius
        defocusDiskV = v * defocusRadius
    }
    
    func getRay<R>(_ i: Int, _ j: Int, rng: inout R) -> Ray where R: RandomNumberGenerator{
        let offset = sampleSquare(rng: &rng)
        let pixelSample = pixel00 + (Double(i) + offset.x) * pixelDX + (Double(j) + offset.y) * pixelDY
        let rayOrigin = (defocusAngle <= 0) ? cameraCenter : defocusDiskSample(rng: &rng)
        let rayDirection = (pixelSample - rayOrigin)//.normalized
        return Ray(origin: rayOrigin, direction: rayDirection)
    }
    private func sampleSquare<R>(rng: inout R) -> Vec3 where R: RandomNumberGenerator{
        // random point in the [-.5, -.5] - [.5, .5] square
        return Vec3(randomDouble(rng: &rng) - 0.5, randomDouble(rng: &rng) - 0.5, 0)
    }
    private func defocusDiskSample<R>(rng: inout R) -> Point3 where R: RandomNumberGenerator{
        let p = Vec3.randomInUnitDisk(rng: &rng)
        return cameraCenter + p.x * defocusDiskU + p.y * defocusDiskV
    }
}

/*
 Camera Center (apex of cone)
                         ●
                        /|\
                       / | \
       defocusAngle-->/  |  \
                     /   |   \
                    /    |    \
                   /     |     \
                  /      |      \
                 /_______|_______\
                                  
                [defocus disk at focal distance]
                <----- radius ---->
 */
