//
//  RideCardView.swift
//  
//
//  Created by Razvan Benga on 07.06.2023.
//

import SwiftUI
import Models
import Theme

extension Ride {
  public var formattedDate: String {
    DateFormatter.rideDateFormatter.string(from: date)
  }
  
  public var formattedDistance: String {
    String(format: "%.1f", distance)
  }
  
  public var formattedDuration: String {
    let hours = duration / 60
    let minutes = duration % 60
    
    switch (hours, minutes) {
    case (0, 0):
      return ""
    case (_, 0):
      return "\(hours)h"
    case (0, _):
      return "\(minutes)min"
    default:
      return "\(hours)h, \(minutes)min"
    }
  }
}

public struct RideCardView: View {
  private let ride: Ride
  private let backgroundColor: Color
  private let onTapGesture: () -> Void
  private let onEditTap: () -> Void
  private let onDeleteTap: () -> Void
  
  public init(
    ride: Ride,
    backgroundColor: Color,
    onTapGesture: @escaping () -> Void,
    onEditTap: @escaping () -> Void,
    onDeleteTap: @escaping () -> Void
  ) {
    self.ride = ride
    self.backgroundColor = backgroundColor
    self.onTapGesture = onTapGesture
    self.onEditTap = onEditTap
    self.onDeleteTap = onDeleteTap
  }
  
  public var body: some View {
    VStack {
      HStack {
        HStack {
          Theme.Image.bikesIcon.value
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 15, height: 15)
            .padding(2)
            .overlay(
              Circle()
                .stroke(.white, lineWidth: 2)
            )
          Text(ride.name)
            .font(.bikeNameFont)
        }
        .foregroundColor(.white)
        
        Spacer()
        
        OverflowPopupView(
          onEditTap: self.onEditTap,
          onDeleteTap: self.onDeleteTap
        )
      }
      
      HStack {
        VStack(alignment: .leading) {
          HStack(spacing: 0) {
            Text("Bike: ")
              .font(.textFont)
            Text(ride.bikeName)
              .font(.bikeServiceDueFont)
          }
          
          HStack(spacing: 0) {
            Text("Distance: ")
              .font(.textFont)
            Text(ride.formattedDistance)
              .font(.bikeServiceDueFont)
          }
          
          HStack(spacing: 0) {
            Text("Duration: ")
              .font(.textFont)
            Text("\(ride.formattedDuration)")
              .font(.bikeServiceDueFont)
          }
          
          HStack(spacing: 0) {
            Text("Date: ")
              .font(.textFont)
            Text(ride.formattedDate)
              .font(.bikeServiceDueFont)
          }
        }
        .foregroundColor(.white)
        
        Spacer()
      }
    }
    .padding()
    .background(backgroundColor)
    .cornerRadius(6)
    .onTapGesture {
      onTapGesture()
    }
  }
}

struct RideCardView_Previews: PreviewProvider {
  static var previews: some View {
    RideCardView(
      ride: Ride.mock,
      backgroundColor: Theme.AppColor.appDarkBlue.value,
      onTapGesture: {},
      onEditTap: {},
      onDeleteTap: {}
    )
  }
}
