//
//  Positionable.swift
//  ARKitInteraction
//
//  Created by Niels van Hoorn on 18/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

protocol Positionable: class {
    var position: SCNVector3 { get set }
    var simdPosition: simd_float3 { get set }
    var parent: SCNNode? { get }

    /// Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentModelObjectDistances: [Float] { get set }
}

extension Positionable {
    /// - Tag: AdjustOntoPlaneAnchor
    func adjustOntoPlaneAnchor(_ anchor: ARPlaneAnchor, using node: SCNNode) {
        // Get the object's position in the plane's coordinate system.
        let planePosition = node.convertPosition(position, from: parent)

        // Check that the object is not already on the plane.
        guard planePosition.y != 0 else { return }

        // Add 10% tolerance to the corners of the plane.
        let tolerance: Float = 0.1

        let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
        let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
        let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
        let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance

        guard (minX...maxX).contains(planePosition.x) && (minZ...maxZ).contains(planePosition.z) else {
            return
        }

        // Move onto the plane if it is near it (within 5 centimeters).
        let verticalAllowance: Float = 0.05
        let epsilon: Float = 0.001 // Do not update if the difference is less than 1 mm.
        let distanceToPlane = abs(planePosition.y)
        if distanceToPlane > epsilon && distanceToPlane < verticalAllowance {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = CFTimeInterval(distanceToPlane * 500) // Move 2 mm per second.
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            position.y = anchor.transform.columns.3.y
            SCNTransaction.commit()
        }
    }

    /**
     Set the object's position based on the provided position relative to the `cameraTransform`.
     If `smoothMovement` is true, the new position will be averaged with previous position to
     avoid large jumps.

     - Tag: ModelObjectSetPosition
     */
    func setPosition(_ newPosition: float3, relativeTo cameraTransform: matrix_float4x4, smoothMovement: Bool) {
        let cameraWorldPosition = cameraTransform.translation
        var positionOffsetFromCamera = newPosition - cameraWorldPosition

        // Limit the distance of the object from the camera to a maximum of 10 meters.
        if simd_length(positionOffsetFromCamera) > 10 {
            positionOffsetFromCamera = simd_normalize(positionOffsetFromCamera)
            positionOffsetFromCamera *= 10
        }

        /*
         Compute the average distance of the object from the camera over the last ten
         updates. Notice that the distance is applied to the vector from
         the camera to the content, so it affects only the percieved distance to the
         object. Averaging does _not_ make the content "lag".
         */
        if smoothMovement {
            let hitTestResultDistance = simd_length(positionOffsetFromCamera)

            // Add the latest position and keep up to 10 recent distances to smooth with.
            recentModelObjectDistances.append(hitTestResultDistance)
            recentModelObjectDistances = Array(recentModelObjectDistances.suffix(10))

            let averageDistance = recentModelObjectDistances.average!
            let averagedDistancePosition = simd_normalize(positionOffsetFromCamera) * averageDistance
            simdPosition = cameraWorldPosition + averagedDistancePosition
        } else {
            simdPosition = cameraWorldPosition + positionOffsetFromCamera
        }
    }

    /// Resets the objects poisition smoothing.
    func reset() {
        recentModelObjectDistances.removeAll()
    }
}
