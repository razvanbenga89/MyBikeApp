//
//  NumberFormatterExtensions.swift
//  
//
//  Created by Razvan Benga on 08.06.2023.
//

import Foundation

extension NumberFormatter {
  public static let chartDistanceNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    formatter.groupingSeparator = "."
    formatter.groupingSize = 3
    
    return formatter
  }()
  
  public static let distanceNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 1
    
    return formatter
  }()
}
