//
//  Floor.swift
//  SwiftARlps
//
//  Created by Robert-Hein Hooijmans on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

class Floor: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []
    
    let size: CGFloat = 0.1
    override init() {
        super.init()
        geometry = SCNBox(width: 100, height: 0.1, length: 100, chamferRadius: 0)

        guard let geometry = geometry else { return }
        let physicsShape = SCNPhysicsShape(geometry: geometry)
        physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        physicsBody?.isAffectedByGravity = false

        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red.withAlphaComponent(0.2)
        material.lightingModel = .physicallyBased
        self.geometry?.materials = [material]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
