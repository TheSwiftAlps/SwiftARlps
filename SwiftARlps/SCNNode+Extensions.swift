//
//  SCNNode+Extensions.swift
//  SwiftARlps
//
//  Created by Bojan Markovic  on 11/24/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import Foundation
import SceneKit


extension SCNNode {
    func changeScaleIfPhysicsBodyIncluded(forSize size: CGFloat) {
        self.physicsBody = nil
        self.scale = SCNVector3(size, size, size)
        self.physicsBody = .dynamic()
    }

    func changeColor(color: UIColor) {
        let material = getMaterial(for: color)
        self.geometry?.materials = [material]
    }
}
