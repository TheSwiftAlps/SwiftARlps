/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Coordinates movement and gesture interactions with virtual objects.
*/

import UIKit
import ARKit

/// - Tag: VirtualObjectInteraction
class VirtualObjectInteraction: NSObject, UIGestureRecognizerDelegate {
    
    /// Developer setting to translate assuming the detected plane extends infinitely.
    let translateAssumingInfinitePlane = true
    
    /// The scene view to hit test against when moving virtual content.
    let sceneView: VirtualObjectARView
    
    /**
     The object that has been most recently intereacted with.
     The `selectedObject` can be moved at any time with the tap gesture.
     */
    var selectedObject: VirtualObject?
    
    /// The object that is tracked for use by the pan and rotation gestures.
    private var trackedObject: VirtualObject? {
        didSet {
            guard trackedObject != nil else { return }
            selectedObject = trackedObject
        }
    }
    
    /// The tracked screen position used to update the `trackedObject`'s position in `updateObjectToCurrentTrackingPosition()`.
    private var currentTrackingPositionVector: SCNVector3?
    private var currentTrackingPositionPoint: CGPoint?

    init(sceneView: VirtualObjectARView) {
        self.sceneView = sceneView
        super.init()
        
        let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        rotationGesture.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))

        let swipeGestures = [UISwipeGestureRecognizerDirection.down, UISwipeGestureRecognizerDirection.up, UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.right].map { addSwipeGesture(for: $0) }

        // Add gestures to the `sceneView`.
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(rotationGesture)
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(pinchGesture)

}
    
    func addSwipeGesture(for direction: UISwipeGestureRecognizerDirection) -> UIGestureRecognizer {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(throwObject(_:)))
        swipeGesture.direction = direction
        swipeGesture.numberOfTouchesRequired = 3
        sceneView.addGestureRecognizer(swipeGesture)
        return swipeGesture
    }
    
    // MARK: - Gesture Actions
    
    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            guard let object = selectedObject else { return }
            let scaleValue: Float = Float(gesture.scale)
            if object.physicsBody == nil {
                object.scale = SCNVector3(scaleValue, scaleValue, scaleValue)
            } else {
                object.changeScaleIfPhysicsBodyIncluded(forSize: CGFloat(scaleValue))
            }
            print("state changed")
        default:
            break
        }
    }
    
    @objc
    func didPan(_ gesture: ThresholdPanGesture) {
        switch gesture.state {
        case .began:
            // Check for interaction with a new object.
            if let object = objectInteracting(with: gesture, in: sceneView) {
                trackedObject = object
                trackedObject?.physicsBody?.isAffectedByGravity = false
            }
            
        case .changed where gesture.isThresholdExceeded:
            guard let object = trackedObject else { return }
            let translation = gesture.translation(in: sceneView)

            let currentPosition = currentTrackingPositionPoint ?? CGPoint(sceneView.projectPoint(object.position))

            // The `currentTrackingPositionPoint` is used to update the `selectedObject` in `updateObjectToCurrentTrackingPosition()`.
            currentTrackingPositionPoint = CGPoint(x: currentPosition.x + translation.x, y: currentPosition.y + translation.y)

            currentTrackingPositionVector = SCNVector3.init(Float(object.position.x) + Float(translation.x / 1000), Float(object.position.y) - Float(translation.y / 1000), object.position.z)

            gesture.setTranslation(.zero, in: sceneView)
            
        case .changed:
            // Ignore changes to the pan gesture until the threshold for displacment has been exceeded.
            break
            
        default:
            // Clear the current position tracking.
            currentTrackingPositionVector = nil
            currentTrackingPositionPoint = nil
            trackedObject?.physicsBody?.isAffectedByGravity = true
            trackedObject = nil
        }
    }

    /**
     If a drag gesture is in progress, update the tracked object's position by
     converting the 2D touch location on screen (`currentTrackingPositionVector`) to
     3D world space.
     This method is called per frame (via `SCNSceneRendererDelegate` callbacks),
     allowing drag gestures to move virtual objects regardless of whether one
     drags a finger across the screen or moves the device through space.
     - Tag: updateObjectToCurrentTrackingPosition
     */
    @objc
    func updateObjectToCurrentTrackingPosition() {
        guard let object = trackedObject, let positionVector = currentTrackingPositionVector, let positionPoint = currentTrackingPositionPoint else { return }
        if object.physicsBody == nil {
            translate(object, basedOn: positionPoint, infinitePlane: translateAssumingInfinitePlane)
        } else {
            object.position = positionVector
        }
    }

    /// - Tag: didRotate
    @objc
    func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.state == .changed else { return }
        
        /*
         - Note:
          For looking down on the object (99% of all use cases), we need to subtract the angle.
          To make rotation also work correctly when looking from below the object one would have to
          flip the sign of the angle depending on whether the object is above or below the camera...
         */
        trackedObject?.eulerAngles.y -= Float(gesture.rotation)
        
        gesture.rotation = 0
    }
    
    @objc
    func didTap(_ gesture: UITapGestureRecognizer) {
        let touchLocation = gesture.location(in: sceneView)
        
        if let tappedObject = sceneView.virtualObject(at: touchLocation) {
            // Select a new object.
            selectedObject = tappedObject
        } else if let object = selectedObject {
            // Teleport the object to whereever the user touched the screen.
            translate(object, basedOn: touchLocation, infinitePlane: false)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Allow objects to be translated and rotated at the same time.
        return true
    }
    
    @objc
    func throwObject(_ gesture: UISwipeGestureRecognizer) {
        if let _ = selectedObject {
            var x = 0
            var y = 0
            var z = 0
            switch gesture.direction {
            case .down:
                x = 0
                z = 5
            case .up:
                x = 0
                z = -5
            case .right:
                x = 5
                z = 0
            case .left:
                x = -5
                z = 0
            default:
                break
            }
            //throw the object using the direction and velocity of the swipe gesture
            print("\(sceneView.session.currentFrame?.camera.transform)")
            let force = simd_make_float4(Float(x), Float(y), Float(z), 0)
            let rotatedForce = simd_mul(sceneView.session.currentFrame!.camera.transform, force)
            let vectorForce = SCNVector3(x:rotatedForce.x, y:rotatedForce.y, z:rotatedForce.z)
            selectedObject?.physicsBody?.applyForce(vectorForce, asImpulse: true)
        }
    }

    /// A helper method to return the first object that is found under the provided `gesture`s touch locations.
    /// - Tag: TouchTesting
    private func objectInteracting(with gesture: UIGestureRecognizer, in view: ARSCNView) -> VirtualObject? {
        for index in 0..<gesture.numberOfTouches {
            let touchLocation = gesture.location(ofTouch: index, in: view)
            
            // Look for an object directly under the `touchLocation`.
            if let object = sceneView.virtualObject(at: touchLocation) {
                return object
            }
        }
        
        // As a last resort look for an object under the center of the touches.
        return sceneView.virtualObject(at: gesture.center(in: view))
    }
    
    // MARK: - Update object position

    /// - Tag: DragVirtualObject
    private func translate(_ object: VirtualObject, basedOn screenPos: CGPoint, infinitePlane: Bool) {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform,
            let (position, _, isOnPlane) = sceneView.worldPosition(fromScreenPosition: screenPos,
                                                                   objectPosition: object.simdPosition,
                                                                   infinitePlane: infinitePlane) else { return }
        
        /*
         Plane hit test results are generally smooth. If we did *not* hit a plane,
         smooth the movement to prevent large jumps.
         */
        object.setPosition(position, relativeTo: cameraTransform, smoothMovement: !isOnPlane)
    }
}

/// Extends `UIGestureRecognizer` to provide the center point resulting from multiple touches.
extension UIGestureRecognizer {
    func center(in view: UIView) -> CGPoint {
        let first = CGRect(origin: location(ofTouch: 0, in: view), size: .zero)

        let touchBounds = (1..<numberOfTouches).reduce(first) { touchBounds, index in
            return touchBounds.union(CGRect(origin: location(ofTouch: index, in: view), size: .zero))
        }

        return CGPoint(x: touchBounds.midX, y: touchBounds.midY)
    }
}
