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

    var box: SCNBox
    var size: CGFloat = 0.1

    override init() {
        let image = #imageLiteral(resourceName: "swizz")
        size = image.size.width/1000
        let box = SCNBox(width: size,
                         height: size,
                         length: size, chamferRadius: 0.002)
        self.box = box

        let images = [#imageLiteral(resourceName: "swizz"),#imageLiteral(resourceName: "swizz"),#imageLiteral(resourceName: "polish"),#imageLiteral(resourceName: "polish"),#imageLiteral(resourceName: "sweden"),#imageLiteral(resourceName: "sweden")]
        let imageMaterials = images.map({ (image) -> SCNMaterial in
            let imageMaterial = SCNMaterial()
            imageMaterial.diffuse.contents = image
            return imageMaterial
        })

        box.materials = imageMaterials

        super.init()

        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    }

    func saveScale(factor: CGFloat) {
        size *= factor
    }

    func scale(factor: CGFloat) -> Void {
        self.box = SCNBox(width: size*factor,
                          height: size*factor,
                          length: size*factor,
                          chamferRadius: 0)


        let images = [#imageLiteral(resourceName: "swizz"),#imageLiteral(resourceName: "swizz"),#imageLiteral(resourceName: "polish"),#imageLiteral(resourceName: "polish"),#imageLiteral(resourceName: "sweden"),#imageLiteral(resourceName: "sweden")]
        let imageMaterials = images.map({ (image) -> SCNMaterial in
            let imageMaterial = SCNMaterial()
            imageMaterial.diffuse.contents = image
            return imageMaterial
        })

        box.materials = imageMaterials
        geometry = box
        updatePhysicsBody()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
