//
//  Plane.swift
//  SwiftARlps
//
//  Created by Niels van Hoorn on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit
import ARKit

let planeHeight: Float = 0.1

extension SCNNode {
    func updatePhysicsBody() {
        guard let geometry = geometry,
            let currentBody = physicsBody,
            let currentShape = currentBody.physicsShape else {
                return
        }
        let shape = SCNPhysicsShape(geometry: geometry, options: currentShape.options)
        let body = SCNPhysicsBody(type: currentBody.type, shape: shape)
        body.isAffectedByGravity = currentBody.isAffectedByGravity
        physicsBody = body
    }
}

class Plane: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []
    let plane: SCNBox
    let planeNode: SCNNode
    let planeHeight: Float = 0.1
    override init() {
        plane = SCNBox(width: 0.5, height: CGFloat(planeHeight), length: 0.5, chamferRadius: 0)
        planeNode = SCNNode(geometry: plane)
        super.init()
        show(false)
        addChildNode(planeNode)
    }

    func show(_ show: Bool) {
        var materials = Array(repeating: getMaterial(for: UIColor.clear), count: 6)
        if show {
            materials[4] = getMaterial(for: UIColor(white: 1, alpha: 0.3))
        }
        plane.materials = materials
    }

    func update(for anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.length = CGFloat(anchor.extent.z)
        planeNode.position = SCNVector3(anchor.center.x, -planeHeight/2, anchor.center.z)
        let shape = SCNPhysicsShape(geometry: plane, options: nil)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        planeNode.physicsBody?.isAffectedByGravity = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
