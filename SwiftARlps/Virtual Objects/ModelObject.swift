/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A `SCNReferenceNode` subclass for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit


class ModelObject: SCNReferenceNode, Positionable {
    internal var recentModelObjectDistances: [Float] = []
    /// The model name derived from the `referenceURL`.
    var modelName: String {
        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
    }
}

extension ModelObject {
    // MARK: Static Properties and Methods
    
    /// Loads all the model objects within `Models.scnassets`.
    static let availableObjects: [ModelObject] = {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!

        return fileEnumerator.flatMap { element in
            let url = element as! URL

            guard url.pathExtension == "scn" else { return nil }

            return ModelObject(url: url)
        }
    }()
    
    /// Returns a `ModelObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> ModelObject? {
        if let modelObjectRoot = node as? ModelObject {
            return modelObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `ModelObject`.
        return existingObjectContainingNode(parent)
    }
}

extension Collection where Iterator.Element == Float, IndexDistance == Int {
    /// Return the mean of a list of Floats. Used with `recentModelObjectDistances`.
    var average: Float? {
        guard !isEmpty else {
            return nil
        }

        let sum = reduce(Float(0)) { current, next -> Float in
            return current + next
        }

        return sum / Float(count)
    }
}
