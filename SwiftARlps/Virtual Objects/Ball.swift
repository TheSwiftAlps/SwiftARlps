//
//  Sphere.swift
//  SwiftARlps
//
//  Created by Niels van Hoorn on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

class Ball: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []
    
    let text: SCNText
    override init() {
        self.text = SCNText(string: "SwiftAlps", extrusionDepth: 1)
        self.text.font = UIFont.systemFont(ofSize: 10, weight: .light)
        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = UIColor.blue
        colorMaterial.shininess = 1.0
        text.materials = [colorMaterial]
        
        super.init()
        
//        let angle = CGFloat.pi / 3.0
//        self.rotation = SCNVector4Make(1, 0, 0, Float(angle))
        self.geometry = text
        let shape = SCNPhysicsShape(geometry: text, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
