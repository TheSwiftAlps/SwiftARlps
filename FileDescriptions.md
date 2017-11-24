## ViewController.swift

* Does the setup of the scene and it’s elements
* Contains an `updateQueue` property on which the adding and deleting of nodes
  needs to be scheduled (automatic through `placeVirtualObject()`)

## VirtualObjectARView.swift

* Subclass of `ARSCNView`, which comes with ARKit
* Keeps the position in the real world synced with the position in the virtual
  world
* Has some helper methods converting from screen to the virtual world or doing
  hit testing

## ViewController+Actions.swift

* Handles the actions like adding objects
* Is where you would put `@IBAction`s

## ViewController+ARSCNViewDelegate.swift

* Contains the callbacks from ARKit into our app
* Adjusts all the objects back to the detected plane

## ViewController+ObjectSelection.swift

* Contains `func placeVirtualObject(_ virtualObject: VirtualObject)`
* Handles the selecting of the build-in model objects

## VirtualObjectInteraction.swift

* Handles all interaction with `VirtualObject`s
* Contains all the Gesture Recognizers and the handling of them

## VirtualObjectList.swift

* Manages all virtual objects in the scene

## VirtualObject.swift

* Type of objects that we’re going to add to the scene
* Combination of `SCNNode` and `Positionable` protocol

## Cube.swift

* Example of a custom VirtualObject that can be added

## Main.storyboard

* Set’s up the scene and UI
* Try to modify as little as possible to avoid merge conflicts
