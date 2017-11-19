//
//  VirtualObjectManager.swift
//  ARKitInteraction
//
//  Created by Niels van Hoorn on 18/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class VirtualObjectList {
    var loadedModels: [ModelObject] {
        return objects.flatMap({ $0 as? ModelObject })
    }

    private(set) var objects: [VirtualObject] = []

    private(set) var isLoading = false

    // MARK: - Loading object

    /**
     Loads a `ModelObject` on a background queue. `loadedHandler` is invoked
     on a background queue once `object` has been loaded.
     */
    private func loadModelObject(_ object: ModelObject, loadedHandler: @escaping (ModelObject) -> Void) {
        isLoading = true
        // Load the content asynchronously.
        DispatchQueue.global(qos: .userInitiated).async {
            object.reset()
            object.load()

            self.isLoading = false
            loadedHandler(object)
        }
    }

    func add(object: VirtualObject) {
        objects.append(object)
    }
    
    func add(model: ModelObject, addedHandler: @escaping (ModelObject) -> Void) {
        loadModelObject(model, loadedHandler: { [unowned self] model in
            self.add(object: model)
            addedHandler(model)
        })
    }

    func remove(object: VirtualObject) {
        // This objects.index(of:) would be more logical here, but that doesn't work.
        guard let objectIndex = objects.index(where:{ obj in object == obj}) else {
            fatalError("Programmer error: Failed to lookup virtual object in scene.")
        }
        objects[objectIndex].removeFromParentNode()
        objects.remove(at: objectIndex)
    }

    func removeAllObjects() {
        // Reverse the indicies so we don't trample over indicies as objects are removed.
        for object in objects.reversed() {
            remove(object: object)
        }
    }

}
