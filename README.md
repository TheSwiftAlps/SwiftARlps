[![BuddyBuild](https://dashboard.buddybuild.com/api/statusImage?appID=5a13e4c292ae680001a82664&branch=master&build=latest)](https://dashboard.buddybuild.com/apps/5a13e4c292ae680001a82664/build/latest?branch=master)

## 🏃‍♀️ Getting started

* Open `SwiftARlps.xcodeproj`.
* Select a development team in the project settings.
* Build and run on your device.

Point your camera at a surface, wait until it detects a surface and then press
one of the buttons to place an object.

## Process

* 👩‍👦 Pair up with another attendee.
* 🍴 Fork the repository, and optionally create a branch.
* 💡 Think of a feature to add, you can come up with something yourself or
  choose from the [Issues](https://github.com/TheSwiftAlps/SwiftARlps/issues).
* 🎯 Commit and push your work, and create a
  [Pull Request](https://github.com/TheSwiftAlps/SwiftARlps/pulls).

## 🦉 Tips

* Start by looking at the FileDescriptions.md file for a description of what
  files have which responsibility.
* Choose a simple feature to add, you can add more complexity later.
* Don't worry about the UI too much, just try make something work.
* The units of ARKit is in meters, so be sure you don't place something 200 away
* There are a bunch of icons to choose from in `Icons.xcassets`.
* If you want to show a message to the user, you can use the
  `StatusViewController` with a `showMessage(_: String, autoHide: Bool)` method.
* Don't be afraid to remove some code if it blocks your current idea.
* When adding kind of new objects, start by copy-pasting an existing subclass of
  `SCNNode` (like `Cube`)
* When doing something with `VirtualObject`s see if you can add it as an
  extension to `SCNNode`

## 📚 Resources

* [Handling 3D Interaction and UI Controls in Augmented Reality](https://developer.apple.com/documentation/arkit/handling_3d_interaction_and_ui_controls_in_augmented_reality)
* [ARKit Framework](https://developer.apple.com/documentation/arkit)
* [WWDC 2017 - Session 602, Introducing ARKit: Augmented Reality for iOS ](https://developer.apple.com/videos/play/wwdc2017/602/)
* [AR Human Interface Guidelines](https://developer.apple.com/ios/human-interface-guidelines/technologies/augmented-reality/)
* [Performing Spatial Transformations](https://www.toptal.com/javascript/3d-graphics-a-webgl-tutorial#performing-spatial-transformations)

## 💡 Inspiration

* [Made With ARKit](http://www.madewitharkit.com)
* [ARPaint](https://www.toptal.com/swift/ios-arkit-tutorial-drawing-in-air-with-fingers)
  ([Video](https://www.youtube.com/watch?v=gb9E0n8m5pE),
  [GitHub](https://github.com/oabdelkarim/ARPaint))
