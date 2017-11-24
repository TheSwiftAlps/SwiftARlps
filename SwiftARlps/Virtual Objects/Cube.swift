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
        geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        guard let geometry = geometry else { return }
        
        let physicsShape = SCNPhysicsShape(geometry: geometry)
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        physicsBody?.friction = 1
        physicsBody?.restitution = 0

        // This positions this node's content on top of it's coordinate, so it's placed on top of a plane, instead of halfway through
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.lightingModel = .physicallyBased
        self.geometry?.materials = [material]
        
        position = SCNVector3(0, 2, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
