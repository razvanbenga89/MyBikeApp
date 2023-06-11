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
  
  @Localized(key: "delete_alert_message")
  public static var deleteAlertMessage
  
  @Localized(key: "delete_action")
  public static var deleteAction
  
  @Localized(key: "edit_action")
  public static var editAction
  
  @Localized(key: "service_overdue_message")
  public static var serviceOverdueMessage
  
  @Localized(key: "mountain_bike_type")
  public static var mountainBikeType
  
  @Localized(key: "road_bike_type")
  public static var roadBikeType
  
  @Localized(key: "electric_bike_type")
  public static var electricBikeType
  
  @Localized(key: "hybrid_bike_type")
  public static var hybridBikeType
  
  @Localized(key: "wheels")
  public static var wheels
  
  @Localized(key: "serviceIn")
  public static var serviceIn
  
  @Localized(key: "rides")
  public static var rides
  
  @Localized(key: "total_rides_distance")
  public static var totalRidesDistance
  
  @Localized(key: "bike_name_placeholder")
  public static var bikeNamePlaceholder
  
  @Localized(key: "required_field_message")
  public static var requiredFieldMessage
  
  @Localized(key: "wheel_size_placeholder")
  public static var wheelSizePlaceholder
  
  @Localized(key: "service_in_placeholder")
  public static var serviceInPlaceholder
  
  @Localized(key: "default_bike_placeholder")
  public static var defaultBikePlaceholder
  
  @Localized(key: "done_action")
  public static var doneAction
  
  @Localized(key: "save_action")
  public static var saveAction
  
  @Localized(key: "edit_bike_title")
  public static var editBikeTitle
  
  @Localized(key: "bikes_title")
  public static var bikesTitle
  
  @Localized(key: "rides_title")
  public static var ridesTitle
  
  @Localized(key: "settings_title")
  public static var settingsTitle
  
  @Localized(key: "add_ride_action")
  public static var addRideAction
  
  @Localized(key: "add_ride_title")
  public static var addRideTitle
  
  @Localized(key: "edit_ride_title")
  public static var editRideTitle
  
  @Localized(key: "all_rides_statistics")
  public static var allRidesStatistics

  @Localized(key: "bike")
  public static var bike
  
  @Localized(key: "distance")
  public static var distance
  
  @Localized(key: "duration")
  public static var duration
  
  @Localized(key: "date")
  public static var date

  @Localized(key: "hours")
  public static var hours
  
  @Localized(key: "minutes")
  public static var minutes
  
  @Localized(key: "duration_placeholder")
  public static var durationPlaceholder
  
  @Localized(key: "date_placeholder")
  public static var datePlaceholder
  
  @Localized(key: "notification_service_in")
  public static var notificationServiceIn
  
  @Localized(key: "notification_service_overdue")
  public static var notificationServiceOverdue

  @Localized(key: "ride_title_placeholder")
  public static var rideTitlePlaceholder
  
  @Localized(key: "bike_placeholder")
  public static var bikePlaceholder
  
  @Localized(key: "distance_placeholder")
  public static var distancePlaceholder

  @Localized(key: "distance_units_placeholder")
  public static var distanceUnitsPlaceholder
  
  @Localized(key: "service_reminder_placeholder")
  public static var serviceReminderPlaceholder
  
  @Localized(key: "mark_latest_service")
  public static var markLatestService
  
  @Localized(key: "latest_service")
  public static var latestService
}
