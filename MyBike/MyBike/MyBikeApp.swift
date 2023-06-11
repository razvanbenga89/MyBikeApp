//
//  MyBikeApp.swift
//  MyBike
//
//  Created by Razvan Benga on 29.05.2023.
//

import SwiftUI
import AppFeature

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var willPresentNotification: ((UNNotification) -> Void)?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    return true
  }
  
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    // Update the app interface directly.
    willPresentNotification?(notification)
    
    // Show a banner
    completionHandler(.sound)
  }
}

@main
struct MyBikeApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView(model: buildAppModel())
        .preferredColorScheme(.dark)
    }
  }
  
  func buildAppModel() -> AppModel {
    let model = AppModel()
    appDelegate.willPresentNotification = {
      model.willPresentNotification($0)
    }
    
    return model
  }
}
