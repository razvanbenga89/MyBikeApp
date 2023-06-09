//
//  Theme.swift
//  
//
//  Created by Razvan Benga on 22.05.2023.
//

import SwiftUI

public enum Theme {
  public enum AppColor: String {
    case appBlack
    case appDarkBlue
    case appGreyBlue
    case appGrey
    case appLightBlue
    case appNavy
    case appWhite
    
    public var value: SwiftUI.Color {
      SwiftUI.Color(rawValue, bundle: Bundle.module)
    }
  }
  
  public enum BikeColor: String, CaseIterable {
    case bikeBeige
    case bikeBlue
    case bikeGreen
    case bikeYellow
    case bikeOrange
    case bikeRed
    case bikeOcean
    case bikeBrown
    case bikeLightBlue
    case bikePink
    case bikeWhite
    
    public var value: SwiftUI.Color {
      SwiftUI.Color(rawValue, bundle: Bundle.module)
    }
  }
  
  public enum Image: String {
    case bikesIcon
    case ridesIcon
    case settingsIcon
    case missingBikesCard
    case dottedLine
    case bikeMtbBigWheels
    case bikeMtbMiddle
    case bikeMtbOver
    case bikeMtbSmallWheels
    case bikeRoadBigWheels
    case bikeRoadMiddle
    case bikeRoadOver
    case bikeRoadSmallWheels
    case bikeElectricBigWheels
    case bikeElectricMiddle
    case bikeElectricOver
    case bikeElectricSmallWheels
    case bikeHybridBigWheels
    case bikeHybridMiddle
    case bikeHybridOver
    case bikeHybridSmallWheels
    case requiredIcon
    case dropDownIcon
    case addIcon
    case overflowIcon
    case loadingCircleIcon
    case loadingWrenchIcon
    case loadingBoltIcon
    case deleteIcon
    case editIcon
    case missingRides
    case statsIcon
    
    public var value: SwiftUI.Image {
      SwiftUI.Image(rawValue, bundle: Bundle.module)
    }
  }
}

extension Color {
  public static var toolbarBackgroundColor: Color {
    Theme.AppColor.appNavy.value
  }
  
  public static var defaultBackgroundColor: Color {
    Theme.AppColor.appBlack.value
  }
}

extension Image {
  public static var bikesIcon: Image {
    Theme.Image.bikesIcon.value
  }
  
  public static var ridesIcon: Image {
    Theme.Image.ridesIcon.value
  }
  
  public static var settingsIcon: Image {
    Theme.Image.settingsIcon.value
  }
  
  public static var missingBikesCard: Image {
    Theme.Image.missingBikesCard.value
  }
  
  public static var dottedLine: Image {
    Theme.Image.dottedLine.value
  }
}

extension Font {
  public static var buttonFont: Font {
    .system(size: 15, weight: .regular)
  }
  
  public static var textFont: Font {
    .system(size: 17, weight: .regular)
  }
  
  public static var navBarTitleFont: Font {
    .system(size: 20, weight: .semibold)
  }
  
  public static var bikeNameFont: Font {
    .system(size: 20, weight: .semibold)
  }
  
  public static var bikeServiceDueFont: Font {
    .system(size: 17, weight: .semibold)
  }
  
  public static var alertTitleFont: Font {
    .system(size: 17, weight: .semibold)
  }
  
  public static var alertMessageFont: Font {
    .system(size: 17, weight: .regular)
  }

  public static var navBarItemFont: Font {
    .system(size: 17, weight: .regular)
  }
  
  public static var textFieldFont: Font {
    .system(size: 14, weight: .regular)
  }
  
  public static var textFieldPlaceholderFont: Font {
    .system(size: 12, weight: .regular)
  }
}
