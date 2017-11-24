//
//  BallCube.swift
//  SwiftARlps
//
//  Created by Adrian Kosmaczewski on 24.11.17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit

class BallCube: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []

    let box: SCNBox
    let ball = Ball()
    let cube = Cube()
    let size: CGFloat = 0.1
    let radius: Float = 0.1
    override init() {
        ball.physicsBody = nil
        cube.physicsBody = nil
        self.box = SCNBox(width: size * 2, height: size * 2, length: size * 2, chamferRadius: 0)
        let m = SCNMaterial()
        m.transparency = 0.0
        box.materials = [m]

        super.init()
        self.addChildNode(cube)
        self.addChildNode(ball)
        cube.position = SCNVector3(self.position.x, self.position.y, self.position.z)
        ball.position = SCNVector3(0.0, cube.position.x + Float(cube.size), 0.0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
