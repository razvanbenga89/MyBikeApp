//
//  DateFormatterExtensions.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import Foundation

extension DateFormatter {
  public static let rideDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    return dateFormatter
  }()
  
  public static let ridesSectionDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter
  }()
}
