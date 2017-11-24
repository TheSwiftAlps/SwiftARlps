//
//  EmojiFace.swift
//  SwiftARlps
//
//  Created by Eran Jalink on 24/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit

class EmojiFace: SCNNode, Positionable {
    var recentModelObjectDistances: [Float] = []
    
    let face: SCNBox
    let size: CGFloat = 0.1
    override init() {
        self.face = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        super.init()
        let emoji = "😀".emojiToImage()
        let material = getMaterial(for: emoji as Any)
        face.materials = [material]
        self.geometry = face
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

