//
//  MyBikeApp.swift
//  MyBike
//
//  Created by Razvan Benga on 29.05.2023.
//

import SwiftUI
import AppFeature

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    true
  }
}

@main
struct MyBikeApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView(model: AppViewModel())
        .preferredColorScheme(.dark)
    }
  }
}
