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

    let box: SCNBox
    let size: CGFloat = 0.1
    override init() {
        self.box = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        super.init()
        let material = getMaterial(for: UIColor.black)
        box.materials = [material]
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
