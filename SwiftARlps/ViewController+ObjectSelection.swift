/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for handling virtual object loading and movement
*/

import UIKit
import SceneKit

extension ViewController: ModelObjectSelectionViewControllerDelegate {
    /**
     Adds the specified virtual object to the scene, placed using
     the focus square's estimate of the world-space position
     currently corresponding to the center of the screen.
     
     - Tag: PlaceVirtualObject
     */
    func placeVirtualObject(_ virtualObject: VirtualObject) {
        guard let cameraTransform = session.currentFrame?.camera.transform,
            var focusSquarePosition = focusSquare.lastPosition else {
            statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
            return
        }
        focusSquarePosition.y += 1 
        virtualObjectInteraction.selectedObject = virtualObject
        virtualObject.setPosition(focusSquarePosition, relativeTo: cameraTransform, smoothMovement: false)
        
        updateQueue.async {
            self.sceneView.scene.rootNode.addChildNode(virtualObject)
        }
    }
    
    // MARK: - ModelObjectSelectionViewControllerDelegate
    
    func modelObjectSelectionViewController(_: ModelObjectSelectionViewController, didSelectObject object: ModelObject) {
        virtualObjectList.add(model: object, addedHandler: { [unowned self] loadedObject in
            DispatchQueue.main.async {
                self.hideObjectLoadingUI()
                self.placeVirtualObject(loadedObject)
            }
        })

        displayObjectLoadingUI()
    }
    
    func modelObjectSelectionViewController(_: ModelObjectSelectionViewController, didDeselectObject object: ModelObject) {
        virtualObjectList.remove(object: object)
    }

    // MARK: Object Loading UI

    func displayObjectLoadingUI() {
        // Show progress indicator.
        spinner.startAnimating()
        
        addObjectButton.setImage(#imageLiteral(resourceName: "buttonring"), for: [])

        addObjectButton.isEnabled = false
        isRestartAvailable = false
    }

    func hideObjectLoadingUI() {
        // Hide progress indicator.
        spinner.stopAnimating()

        addObjectButton.setImage(#imageLiteral(resourceName: "candle"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "candle"), for: [.highlighted])

        addObjectButton.isEnabled = true
        isRestartAvailable = true
    }
}
