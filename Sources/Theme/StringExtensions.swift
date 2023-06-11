//
//  StringExtensions.swift
//  
//
//  Created by Razvan Benga on 10.06.2023.
//

import Foundation

extension String {
  public func removeDuplicateCharacters(input: String) -> String {
    let string = self
    var trimmedString = ""
    let preGroups = string.components(separatedBy: input)
    if preGroups.count > 1 {
      trimmedString = preGroups[0] + input + preGroups.dropFirst().joined(separator: "")
      return trimmedString
    } else {
      return string
    }
  }
}
