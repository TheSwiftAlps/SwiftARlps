//
//  Sphere.swift
//  SwiftARlps
//
//  Created by Niels van Hoorn on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

class Sphere: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []
    
    let sphere: SCNSphere
    let radius: Float = 0.1
    override init() {
        self.sphere = SCNSphere(radius: CGFloat(radius))
        let material = getMaterial(for: UIImage(named: "BallMaterial")!)
        material.shininess = 1.0
        sphere.materials = [material]
        super.init()
        self.geometry = sphere
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
