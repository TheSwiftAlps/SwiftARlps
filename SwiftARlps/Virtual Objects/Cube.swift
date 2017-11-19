//
//  Cube.swift
//  ARKitInteraction
//
//  Created by Niels van Hoorn on 18/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

class Cube: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []

    let size: CGFloat = 0.1
    override init() {
        super.init()
        self.geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        // This positions this node's content on top of it's coordinate, so it's placed on top of a plane, instead of halfway through
        self.pivot = SCNMatrix4MakeTranslation(0, Float(-size/2), 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.lightingModel = .physicallyBased
        self.geometry?.materials = [material]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
