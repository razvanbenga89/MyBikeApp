//
//  BikeTypeView.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import SwiftUI
import Models
import Theme
import Localization

extension BikeType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .mtb:
      return Localization.mountainBikeType
    case .road:
      return Localization.roadBikeType
    case .electric:
      return Localization.electricBikeType
    case .hybrid:
      return Localization.hybridBikeType
    }
  }
}

extension WheelSize: CustomStringConvertible {
  public var description: String {
    switch self {
    case .big:
      return "29''"
    case .small:
      return "28''"
    }
  }
}

extension BikeType {
  var bigWheelsImage: some View {
    var image: Image
    
    switch self {
    case .mtb:
      image = Theme.Image.bikeMtbBigWheels.value
    case .road:
      image = Theme.Image.bikeRoadBigWheels.value
    case .electric:
      image = Theme.Image.bikeElectricBigWheels.value
    case .hybrid:
      image = Theme.Image.bikeHybridBigWheels.value
    }
    
    return image
      .resizable()
      .scaledToFit()
      .frame(width: UIScreen.main.bounds.width * 0.66)
  }
  
  var smallWheelsImage: some View {
    var image: Image
    
    switch self {
    case .mtb:
      image = Theme.Image.bikeMtbSmallWheels.value
    case .road:
      image = Theme.Image.bikeRoadSmallWheels.value
    case .electric:
      image = Theme.Image.bikeElectricSmallWheels.value
    case .hybrid:
      image = Theme.Image.bikeHybridSmallWheels.value
    }
    
    return image
      .resizable()
      .scaledToFit()
      .frame(width: UIScreen.main.bounds.width * 0.66)
  }
  
  var middleImage: some View {
    var image: Image
    var widthRatio: CGFloat
    var paddingRatio: CGFloat
    
    switch self {
    case .mtb:
      widthRatio = 0.39
      paddingRatio = 0.125
      image = Theme.Image.bikeMtbMiddle.value
    case .road:
      widthRatio = 0.39
      paddingRatio = 0.125
      image = Theme.Image.bikeRoadMiddle.value
    case .electric:
      widthRatio = 0.4
      paddingRatio = 0.11
      image = Theme.Image.bikeElectricMiddle.value
    case .hybrid:
      widthRatio = 0.39
      paddingRatio = 0.12
      image = Theme.Image.bikeHybridMiddle.value
    }
    
    return image
      .resizable()
      .scaledToFit()
      .frame(width: UIScreen.main.bounds.width * widthRatio)
      .padding(.bottom, UIScreen.main.bounds.width * paddingRatio)
  }
  
  var overImage: some View {
    var image: Image
    var widthRatio: CGFloat
    var paddingBottomRatio: CGFloat
    var paddingTrailingRatio: CGFloat
    
    switch self {
    case .mtb:
      widthRatio = 0.36
      paddingBottomRatio = 0.065
      paddingTrailingRatio = 0.081
      image = Theme.Image.bikeMtbOver.value
    case .road:
      widthRatio = 0.42
      paddingBottomRatio = 0.062
      paddingTrailingRatio = 0.025
      image = Theme.Image.bikeRoadOver.value
    case .electric:
      widthRatio = 0.34
      paddingBottomRatio = 0.066
      paddingTrailingRatio = 0.107
      image = Theme.Image.bikeElectricOver.value
    case .hybrid:
      widthRatio = 0.368
      paddingBottomRatio = 0.061
      paddingTrailingRatio = 0.08
      image = Theme.Image.bikeHybridOver.value
    }
    
    return image
      .resizable()
      .scaledToFit()
      .frame(width: UIScreen.main.bounds.width * widthRatio)
      .padding(.bottom, UIScreen.main.bounds.width * paddingBottomRatio)
      .padding(.trailing, UIScreen.main.bounds.width * paddingTrailingRatio)
  }
}

struct BikeTypeView: View {
  private let type: BikeType
  private let showTypeDescription: Bool
  @Binding private var wheelSize: WheelSize
  @Binding private var bikeColor: Theme.BikeColor
  
  init(
    type: BikeType,
    showTypeDescription: Bool,
    wheelSize: Binding<WheelSize>,
    bikeColor: Binding<Theme.BikeColor>
  ) {
    self.type = type
    self.showTypeDescription = showTypeDescription
    self._wheelSize = wheelSize
    self._bikeColor = bikeColor
  }
  
  var body: some View {
    VStack {
      ZStack(alignment: .bottom) {
        if wheelSize == .big {
          type.bigWheelsImage
        } else {
          type.smallWheelsImage
        }
        type.middleImage
          .foregroundColor(bikeColor.value)
        type.overImage
      }
      
      if showTypeDescription {
        Text(type.description)
          .font(.textFont)
          .foregroundColor(.white)
      }
    }
  }
}
