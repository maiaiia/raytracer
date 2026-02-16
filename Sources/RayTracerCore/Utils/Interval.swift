public struct Interval {
    let left: Double
    let right: Double
    
    static let empty = Interval(Double.infinity, -Double.infinity)
    static let universe: Interval = .init(-Double.infinity, Double.infinity)
    
    public init() {
        left = -Double.infinity
        right = Double.infinity
    }
    
    init(_ left: Double, _ right: Double) {
        self.left = left
        self.right = right
    }
    
    func size() -> Double {
        right - left
    }
    
    func contains(_ value: Double) -> Bool {
        value >= left && value <= right
    }
    
    func surrounds(_ value: Double) -> Bool {
        value > left && value < right
    }
    
    func clamp(_ x: Double) -> Double {
        if x < left {
            return left
        }
        if x > right {
            return right
        }
        return x
    }
    
}
