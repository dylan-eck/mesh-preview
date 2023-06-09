import Foundation
import simd

enum ProjectionType: String, Codable {
    case orthographic
    case perspective
}

class Camera: Codable {
    var horizontalResolution: Float32 = 1920 {
        didSet {
            if (horizontalResolution == oldValue) {return}
            viewMatrixStale = true
            projectionMatrixStale = true
        }
    }
    var verticalResolution: Float32 = 1080 {
        didSet {
            if (verticalResolution == oldValue) {return}
            viewMatrixStale = true
            projectionMatrixStale = true
        }
    }
    
    var verticalFieldOFView: Float32 = 45 {
        didSet {
            if verticalFieldOFView == oldValue { return }
            projectionMatrixStale = true
        }
    }
    
    var nearClippingPlane: Float32 = 0.01 {
        didSet {
            if nearClippingPlane == oldValue { return }
            projectionMatrixStale = true
        }
    }
    
    var farClippingPlane: Float32 = 100 {
        didSet {
            if farClippingPlane == oldValue { return }
            projectionMatrixStale = true
        }
    }
    
    var orthographicFocusPlane: Float32 = 0 {
        didSet {
            if orthographicFocusPlane == oldValue { return }
            projectionMatrixStale = true
        }
    }
    
    var position = Vec3(repeating: 0) {
        didSet {
            if position == oldValue { return }
            viewMatrixStale = true
            projectionMatrixStale = true
        }
    }
    
    var rotation = Vec3(repeating: 0) {
        didSet {
            if rotation == oldValue { return }
            viewMatrixStale = true
            projectionMatrixStale = true
        }
    }
    
    var upDirection = Vec3(0, 1, 0) {
        didSet {
            if upDirection == oldValue { return }
            viewMatrixStale = true
        }
    }
    
    var target: Vec3? = nil {
        didSet {
            if target == oldValue { return }
            viewMatrixStale = true
        }
    }
    
    var projection = ProjectionType.perspective {
        didSet {
            if projection == oldValue { return }
            projectionMatrixStale = true
        }
    }
    
    private var viewMatrix = Mat4(1)
    private var viewMatrixStale = true
    private var projectionMatrix = Mat4(1)
    private var projectionMatrixStale = true
    
    func getViewMatrix() -> Mat4 {
        if viewMatrixStale {
            updateViewMatrix()
            viewMatrixStale = false
        }
        return viewMatrix
    }
    
    func getProjectionMatrix() -> Mat4 {
        if projectionMatrixStale {
            updateProjectionMatrix()
            projectionMatrixStale = false
        }
        return projectionMatrix
    }
    
        
    private func updateViewMatrix() {
        if target != nil {
            viewMatrix = Mat4.lookAt(
                position: position,
                target: target!,
                up: upDirection
            )
        } else {
            let xRotation = Mat4(1.0)
            let yRotation = Mat4(1.0)
            let zRotation = Mat4(1.0)
            let combinedRotation = zRotation * xRotation * yRotation
            
            let translation = Mat4(rows: [
                [1, 0, 0, position.x],
                [0, 1, 0, position.y],
                [0, 0, 1, position.z],
                [0, 0, 0, 1]
            ])
            
            viewMatrix = translation * combinedRotation
        }
    }

    private func updateProjectionMatrix() {    
        let aspectRatio = horizontalResolution / verticalResolution
        
    
        switch projection {
        case .orthographic:
            let nearHeight = orthographicFocusPlane * tan(verticalFieldOFView / 2.0)
            let nearWidth = nearHeight * aspectRatio
            projectionMatrix = Mat4.orthographicProjection(
                left: -nearWidth,
                right:  nearWidth,
                top: nearHeight, bottom: -nearHeight,
                near: nearClippingPlane,
                far: farClippingPlane
            )
        case .perspective:
            projectionMatrix = Mat4.perspectiveProjection(
                fov: verticalFieldOFView,
                aspect: aspectRatio,
                near: nearClippingPlane,
                far: farClippingPlane
            )
        }
    }
    
    init() {
        
    }
    
    enum CodingKeys: String, CodingKey {
        case horizontalResolution
        case verticalResolution
        case verticalFieldOFView
        case nearClippingPlane
        case farClippingPlane
        case orthographicFocusPlane
        case position
        case rotation
        case upDirection
        case target
        case projection
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        horizontalResolution = try container.decode(Float32.self, forKey: .horizontalResolution)
        verticalResolution = try container.decode(Float32.self, forKey: .verticalResolution)
        verticalFieldOFView = try container.decode(Float32.self, forKey: .verticalFieldOFView)
        nearClippingPlane = try container.decode(Float32.self, forKey: .nearClippingPlane)
        farClippingPlane = try container.decode(Float32.self, forKey: .farClippingPlane)
        orthographicFocusPlane = try container.decode(Float32.self, forKey: .orthographicFocusPlane)
        position = try container.decode(Vec3.self, forKey: .position)
        rotation = try container.decode(Vec3.self, forKey: .rotation)
        upDirection = try container.decode(Vec3.self, forKey: .upDirection)
        target = try container.decodeIfPresent(Vec3.self, forKey: .target)
        projection = try container.decode(ProjectionType.self, forKey: .projection)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(horizontalResolution, forKey: .horizontalResolution)
        try container.encode(verticalResolution, forKey: .verticalResolution)
        try container.encode(verticalFieldOFView, forKey: .verticalFieldOFView)
        try container.encode(nearClippingPlane, forKey: .nearClippingPlane)
        try container.encode(farClippingPlane, forKey: .farClippingPlane)
        try container.encode(orthographicFocusPlane, forKey: .orthographicFocusPlane)
        try container.encode(position, forKey: .position)
        try container.encode(rotation, forKey: .rotation)
        try container.encode(upDirection, forKey: .upDirection)
        try container.encodeIfPresent(target, forKey: .target)
        try container.encode(projection, forKey: .projection)
    }
}

