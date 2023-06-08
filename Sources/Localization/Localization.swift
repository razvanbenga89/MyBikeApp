//
//  Localization.swift
//  
//
//  Created by Razvan Benga on 30.05.2023.
//

import Foundation

@propertyWrapper
struct Localized {
  private let key: String
  private let comment: String
  
  var wrappedValue: String {
    NSLocalizedString(key, bundle: Bundle.module, comment: comment)
  }
  
  init(key: String, comment: String = "") {
    self.key = key
    self.comment = comment
  }
}

public enum Localization {
  @Localized(key: "add_bike_action")
  public static var addBikeAction
  
  @Localized(key: "no_bikes_text")
  public static var noBikesText
  
  @Localized(key: "cancel_action")
  public static var cancelAction
  
  @Localized(key: "add_bike_title")
  public static var addBikeTitle
  
  @Localized(key: "no_rides_text")
  public static var noRidesText
}
