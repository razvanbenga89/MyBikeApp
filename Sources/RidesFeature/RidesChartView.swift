//
//  RidesChartView.swift
//  
//
//  Created by Razvan Benga on 07.06.2023.
//

import SwiftUI
import Theme
import Models

extension BikeType {
  var chartDescription: String {
    switch self {
    case .mtb:
      return "MTB"
    case .road:
      return "Road"
    case .electric:
      return "E-Bike"
    case .hybrid:
      return "Hybrid"
    }
  }
  
  var chartColor: Color {
    switch self {
    case .mtb:
      return Theme.BikeColor.bikeOrange.value
    case .road:
      return Theme.BikeColor.bikeRed.value
    case .electric:
      return Theme.BikeColor.bikeWhite.value
    case .hybrid:
      return Theme.BikeColor.bikeYellow.value
    }
  }
}

struct RidesChartView: View {
  struct BikeRides {
    let bikeType: BikeType
    let rides: [Ride]
    
    var ridesTotalDistance: Double {
      rides.reduce(0) {
        $0 + $1.distance
      }
    }
  }
  private let threshhold: Int = 20000
  private var bikeRides: [BikeRides] = []
  
  init(
    rides: [Ride] = []
  ) {
    let groupedRides = Dictionary(grouping: rides) { ride in
      ride.bikeType
    }
    
    self.bikeRides = groupedRides.map { BikeRides(bikeType: $0.key, rides: $0.value) }
    
    let highestTotalDistance = bikeRides
      .sorted(by: { $0.ridesTotalDistance < $1.ridesTotalDistance })
      .last?
      .ridesTotalDistance ?? 0
    
    let count = max(String(Int(highestTotalDistance)).count - 1, 1)
    let power = pow(Double(10), Double(count))
    //self.threshhold = Int(ceil(highestTotalDistance / power) * power)
  }
  
  var body: some View {
    VStack(spacing: 10) {
      HStack {
        Image(systemName: "align.vertical.bottom.fill")
        Text("All Rides Statistics")
        
        Spacer()
      }
      
      VStack(spacing: 0) {
        GeometryReader { proxy in
          ZStack(alignment: .bottom) {
            LazyVStack(spacing: (proxy.size.height - 9) / 10) {
              ForEach(0..<9) { val in
                Rectangle()
                  .fill(Theme.AppColor.appGrey.value)
                  .frame(width: proxy.size.width, height: 1)
              }
            }
            .padding(.vertical, proxy.size.height / 10)
            
            HStack(alignment: .bottom) {
              ForEach(BikeType.allCases) { bikeType in
                Spacer()
                ZStack(alignment: .bottom) {
                  let totalDistanceForBikeType = getRidesTotalDistance(for: bikeType)
                  let minHeight = totalDistanceForBikeType.isEmpty ? 0 : proxy.size.height / 10
                  
                  Rectangle()
                    .fill(bikeType.chartColor)
                    .frame(
                      maxWidth: 60,
                      minHeight: minHeight
                    )
                    .frame(
                      height: calculateChartHeight(
                        bikeType: bikeType,
                        proxy: proxy
                      )
                    )
                    .frame(minHeight: minHeight)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 5)
                    .cornerRadius(5)
                    .padding(.bottom, -5)
                  
                  Text(totalDistanceForBikeType)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                }
                Spacer()
              }
            }
            .frame(maxWidth: .infinity)
          }
        }
        .frame(height: 200)
        
        HStack {
          ForEach(BikeType.allCases) { bikeType in
            HStack {
              Spacer()
              Text(bikeType.chartDescription)
                .multilineTextAlignment(.center)
              Spacer()
            }
          }
        }
        .padding(.vertical, 10)
        .overlay(
          Rectangle()
            .fill(Theme.AppColor.appGrey.value)
            .frame(maxWidth: .infinity, maxHeight: 5),
          alignment: .top
        )
      }
      .overlay(
        RoundedRectangle(cornerRadius: 6)
          .stroke(Theme.AppColor.appGrey.value, lineWidth: 1)
      )
      
      Text("Total: 25.570KM")
    }
    .foregroundColor(.white)
    .padding()
    .background(Theme.AppColor.appDarkBlue.value)
    .cornerRadius(6)
  }
  
  private func getRidesTotalDistance(for bikeType: BikeType) -> String {
    guard let bike = bikeRides.first(where: { $0.bikeType == bikeType }) else {
      return ""
    }
    
    return "\(bike.ridesTotalDistance)"
  }
  
  private func calculateChartHeight(bikeType: BikeType, proxy: GeometryProxy) -> CGFloat {
    guard let bike = bikeRides.first(where: { $0.bikeType == bikeType }) else {
      return 0
    }
    
    let percentage = bike.ridesTotalDistance / Double(threshhold)
    return max(0, (percentage * proxy.size.height))
  }
}

struct RidesChartView_Previews: PreviewProvider {
  static var previews: some View {
    RidesChartView(
      rides: Ride.buildMocks(bikeId: UUID(), bikeName: "MTB")
    )
  }
}
