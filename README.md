# MyBikeApp

This repo contains the full source code for MyBike, an iOS app used for keeping track of bikes maintenance intervals.

## Project Description

This project is built with modularization in mind by taking advantage of swift packages. This allows us to work on features without building the entire application, which improves compile times and SwiftUI preview stability. 

The UI is built entirely in SwiftUI and each screen has it's own ObservableObject model (you can think of it as a view model allthough I've opted for the "model" naming) which handles the business logic and drives the UI. Navigation is driven off of state, using the [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation) package provided by [PointFree](https://www.pointfree.co/).

Local data persistence is achieved through CoreData and UserDefaults.

Side effects are performed using the new Swift concurrency patterns.

Dependency management is driven by the [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) package provided by [PointFree](https://www.pointfree.co/).

## Usage

You can open the MyBike.xcodeproj in Xcode and build the app directly on an iOS simulator or on a device by adding and Apple Id account and changing the Team on the Signing and Capabilities tab. Also, each app module can be run from Xcode independently in order to test SwiftUI previews.

## Requirements
- iOS 16+
- Xcode 14.2.0+

## Acknowledgements

Many of the design patterns are inspired from [PointFree](https://www.pointfree.co/) so big shout-out to them.

External libraries:

https://github.com/pointfreeco/swiftui-navigation  
https://github.com/pointfreeco/swift-dependencies  
https://github.com/aheze/Popovers