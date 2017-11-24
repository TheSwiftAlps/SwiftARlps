/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 UI Actions for the main view controller.
 */

import UIKit
import SceneKit
import Vision

extension ViewController: UIGestureRecognizerDelegate {
    
    
    
    enum SegueIdentifier: String {
        case showObjects
    }
    
    // MARK: - Interface Actions
    
    /// Displays the `ModelObjectSelectionViewController` from the `addObjectButton` or in response to a tap gesture in the `sceneView`.
    @IBAction func showModelObjectSelectionViewController() {
        // Ensure adding objects is an available action and we are not loading another object (to avoid concurrent modifications of the scene).
        guard !addObjectButton.isHidden && !virtualObjectList.isLoading else { return }
        
        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        performSegue(withIdentifier: SegueIdentifier.showObjects.rawValue, sender: addObjectButton)
    }
    
    /// Determines if the tap gesture for presenting the `ModelObjectSelectionViewController` should be used.
    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return virtualObjectList.objects.isEmpty
    }
    
    @IBAction func addCube() {
        guard !addCubeButton.isHidden else { return }
        guard let frame = self.sceneView.session.currentFrame else { return }
        let image = CIImage.init(cvPixelBuffer: frame.capturedImage).oriented(UIDevice.current.orientation.cameraOrientation())
        let facesRequest = VNDetectFaceRectanglesRequest { request, error in
            guard error == nil else { return }
            var index = 0
            if let resultCount = request.results?.count, resultCount < self.emojiFaces.count {
                for i in resultCount..<self.emojiFaces.count {
                    self.emojiFaces[i].removeFromParentNode()
                }
            }
            request.results?.forEach {
                guard let face = $0 as? VNFaceObservation else { return }
                let boundingBox = self.transformBoundingBox(face.boundingBox)
                
                guard let worldCoordinates = self.normalizeWorldCoord(boundingBox) else { return }
                DispatchQueue.main.async {
                    let cube: EmojiFace
                    if self.emojiFaces.count > index {
                        cube = self.emojiFaces[index]
                    }
                    else {
                        cube = EmojiFace()
                        self.emojiFaces.append(cube)
                    }
                    
                    let coordinatesFloat = float3(worldCoordinates.x, worldCoordinates.y, worldCoordinates.z)
                    self.placeVirtualObject(cube, location: coordinatesFloat)
                }
                index += 1
            }
            
        }
        try? VNImageRequestHandler(ciImage: image).perform([facesRequest])
        
        
        //        let cube = Cube()
        //        virtualObjectList.add(object: cube)
        //        DispatchQueue.main.async {
        //            self.placeVirtualObject(cube)
        //        }
    }
    
    @IBAction func addBallCube() {
        guard !addBallCubeButton.isHidden else { return }
        let ballcube = BallCube()
        virtualObjectList.add(object: ballcube)
        DispatchQueue.main.async {
            self.placeVirtualObject(ballcube)
        }
    }
    
    @IBAction func addSphere() {
        guard !addSphereButton.isHidden else { return }
        let sphere = Ball()
        virtualObjectList.add(object: sphere)
        DispatchQueue.main.async {
            self.placeVirtualObject(sphere)
        }
    }
    
    @IBAction func didTapRedButton() {
        guard !changeColorToRedButton.isHidden else { return }
        virtualObjectInteraction.selectedObject?.changeColor(color: UIColor.red)
    }
    
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// - Tag: restartExperience
    func restartExperience() {
        guard isRestartAvailable, !virtualObjectList.isLoading else { return }
        isRestartAvailable = false
        
        statusViewController.cancelAllScheduledMessages()
        
        virtualObjectList.removeAllObjects()
        addObjectButton.setImage(#imageLiteral(resourceName: "candle"), for: [])
        addObjectButton.setImage(#imageLiteral(resourceName: "candle"), for: [.highlighted])
        
        resetTracking()
        
        // Disable restart for a while in order to give the session time to restart.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // All menus should be popovers (even on iPhone).
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceView = button
            popoverController.sourceRect = button.bounds
        }
        
        guard let identifier = segue.identifier,
            let segueIdentifer = SegueIdentifier(rawValue: identifier),
            segueIdentifer == .showObjects else { return }
        
        let objectsViewController = segue.destination as! ModelObjectSelectionViewController
        objectsViewController.modelObjects = ModelObject.availableObjects
        objectsViewController.delegate = self
        
        // Set all rows of currently placed objects to selected.
        for object in virtualObjectList.loadedModels {
            guard let index = ModelObject.availableObjects.index(of: object) else { continue }
            objectsViewController.selectedModelObjectRows.insert(index)
        }
    }
    
    /// Transform bounding box according to device orientation
    ///
    /// - Parameter boundingBox: of the face
    /// - Returns: transformed bounding box
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var size: CGSize
        var origin: CGPoint
        let bounds = sceneView.bounds
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            size = CGSize(width: boundingBox.width * bounds.height,
                          height: boundingBox.height * bounds.width)
        default:
            size = CGSize(width: boundingBox.width * bounds.width,
                          height: boundingBox.height * bounds.height)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            origin = CGPoint(x: boundingBox.minY * bounds.width,
                             y: boundingBox.minX * bounds.height)
        case .landscapeRight:
            origin = CGPoint(x: (1 - boundingBox.maxY) * bounds.width,
                             y: (1 - boundingBox.maxX) * bounds.height)
        case .portraitUpsideDown:
            origin = CGPoint(x: (1 - boundingBox.maxX) * bounds.width,
                             y: boundingBox.minY * bounds.height)
        default:
            origin = CGPoint(x: boundingBox.minX * bounds.width,
                             y: (1 - boundingBox.maxY) * bounds.height)
        }
        
        return CGRect(origin: origin, size: size)
    }
    
    /// In order to get stable vectors, we determine multiple coordinates within an interval.
    ///
    /// - Parameters:
    ///   - boundingBox: Rect of the face on the screen
    /// - Returns: the normalized vector
    private func normalizeWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        
        var array: [SCNVector3] = []
        Array(0...2).forEach{_ in
            if let position = determineWorldCoord(boundingBox) {
                array.append(position)
            }
            usleep(12000) // .012 seconds
        }
        
        if array.isEmpty {
            return nil
        }
        
        return SCNVector3.center(array)
    }
    
    /// Determine the vector from the position on the screen.
    ///
    /// - Parameter boundingBox: Rect of the face on the screen
    /// - Returns: the vector in the sceneView
    private func determineWorldCoord(_ boundingBox: CGRect) -> SCNVector3? {
        let arHitTestResults = sceneView.hitTest(CGPoint(x: boundingBox.midX, y: boundingBox.midY), types: [.featurePoint])
        
        // Filter results that are to close
        if let closestResult = arHitTestResults.filter({ $0.distance > 0.10 }).first {
            //            print("vector distance: \(closestResult.distance)")
            return SCNVector3.positionFromTransform(closestResult.worldTransform)
        }
        return nil
    }
}
