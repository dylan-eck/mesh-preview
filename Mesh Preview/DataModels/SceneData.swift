//
//  SceneDataModel.swift
//  CSCI598D_P02_ECK
//
//  Created by Dylan Eck on 4/15/23.
//

import Foundation

class SceneData: ObservableObject {
    @Published var camera = Camera()
    @Published var lastMouseLocation: Vec2? = nil
    @Published var mouseDelta = Vec2(0, 0)
    @Published var modelURL: URL? = nil

    var cameraDistance: Float32 = 1.0
    @Published var minCameraDistance: Float32 = 0.1
    @Published var maxCameraDistance: Float32 = 100.0
    
    @Published var vertexColors: UInt32 = VertexAttributeColor.rawValue
    
    init() {
        camera.position = Vec3(0, 2, 4)
        camera.orthographicFocusPlane = 4
        camera.target = Vec3(0, 0, 0)
        camera.projection = .perspective
        
        cameraDistance = sqrt(dot(camera.position, camera.position))
    }
    
    func toggleProjection() {
        if camera.projection == .perspective {
            camera.projection = .orthographic
        } else {
            camera.projection = .perspective
        }
    }
    
    func update(viewWidth: Float32, viewHeight: Float32) {
        camera.horizontalResolution = viewWidth
        camera.verticalResolution = viewHeight

        let currentCameraDistance = sqrt(dot(camera.position, camera.position))
        if (abs(cameraDistance - currentCameraDistance) > 0.0001) {
            let cameraDirection = camera.position / currentCameraDistance
            camera.position = cameraDirection * cameraDistance
        }

        
        if mouseDelta != Vec2(0, 0) {            
            let scale: Float32 = 4.0

            let homogeneousPosition = Vec4(camera.position, 1)
            let homogeneousTarget = Vec4(camera.target!, 1)

            var newPosition: Vec4

            let angleRangeX: Float32 = 2 * Float32.pi / camera.horizontalResolution
            let angleRangeY: Float32 = Float32.pi / camera.verticalResolution

            let deltaAngleX = scale * mouseDelta.x * angleRangeX
            let deltaAngleY = scale * mouseDelta.y * angleRangeY

            let xRotation: Mat4 = Mat4.rotate(Mat4(1), deltaAngleX, camera.upDirection)

            newPosition = (xRotation * (homogeneousPosition - homogeneousTarget)) + homogeneousTarget

            let yRotation = Mat4.rotate(Mat4(1), deltaAngleY,
                Vec3(
                    camera.getViewMatrix().transpose[0].x,
                    camera.getViewMatrix().transpose[0].y,
                    camera.getViewMatrix().transpose[0].z
                ))

            newPosition = (yRotation * (newPosition - homogeneousTarget)) + homogeneousTarget
            camera.position = Vec3(newPosition.x, newPosition.y, newPosition.z)
        }
        
        let xzDistanceFromOrigin = sqrt(
            camera.position.x * camera.position.x +
            camera.position.z * camera.position.z
        )

        camera.orthographicFocusPlane = xzDistanceFromOrigin
    }
}
