//
//  UserDefaultsConfig.swift
//  
//
//  Created by Razvan Benga on 09.06.2023.
//

import Foundation
import Models

public enum UserDefaultsConfig {
  private enum Key {
    static let isServiceReminderOn = "isServiceReminderOn"
    static let distanceUnit = "distanceUnit"
    static let serviceReminderDistance = "serviceReminderDistance"
  }
  
  @UserDefault(key: Key.isServiceReminderOn, defaultValue: true)
  public static var isServiceReminderOn: Bool
  
  @UserDefaultRawRepresentable(key: Key.distanceUnit, defaultValue: .km)
  public static var distanceUnit: DistanceUnit
  
  @UserDefault(key: Key.serviceReminderDistance, defaultValue: 100)
  public static var serviceReminderDistance: Int
}

@propertyWrapper
public struct UserDefault<T> {
  let key: String
  let defaultValue: T
  
  public var wrappedValue: T {
    get {
      UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    } set {
      UserDefaults.standard.setValue(newValue, forKey: key)
    }
  }
  
  public init(key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
}

@propertyWrapper
public struct UserDefaultRawRepresentable<T: RawRepresentable> {
  let key: String
  let defaultValue: T
  
  public var wrappedValue: T {
    get {
      guard let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) else {
        return defaultValue
      }
      
      return value
    } set {
      UserDefaults.standard.setValue(newValue.rawValue, forKey: key)
    }
  }
  
  public init(key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
}
