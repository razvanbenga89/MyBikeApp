# MyBikeApp

This repo contains the full source code for MyBike, an iOS app used for keeping track of bikes maintenance intervals.

## Project Description

This project is built with modularization in mind by taking advantage of swift packages. This allows us to work on features without building the entire application, which improves compile times and SwiftUI preview stability. 

The UI is built entirely in SwiftUI and each screen has it's own ObservableObject model (you can think of it as a view model allthough I've opted for the "model" naming) which handles the business logic and drives the UI. Navigation is driven off of state, using the [swiftui-navigation](https://github.com/pointfreeco/swiftui-navigation) package provided by [PointFree](https://www.pointfree.co/).

Local data persistence is achieved through CoreData and UserDefaults.

Side effects are performed using the new Swift concurrency patterns.

Dependency management is driven by the [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) package provided by [PointFree](https://www.pointfree.co/).

## Acknowledgements

Many of the design patterns are inspired from [PointFree](https://www.pointfree.co/) so big shout-out to them.

External libraries:

https://github.com/pointfreeco/swiftui-navigation  
https://github.com/pointfreeco/swift-dependencies  
https://github.com/aheze/Popovers