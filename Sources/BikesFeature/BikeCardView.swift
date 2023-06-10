//
//  BikeCardView.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import SwiftUI
import Theme
import Models
import Localization

struct BikeCardView: View {  
  private let bike: Bike
  private let onTapGesture: () -> Void
  private let onEditTap: () -> Void
  private let onDeleteTap: () -> Void
  
  init(
    bike: Bike,
    onTapGesture: @escaping () -> Void,
    onEditTap: @escaping () -> Void,
    onDeleteTap: @escaping () -> Void
  ) {
    self.bike = bike
    self.onTapGesture = onTapGesture
    self.onEditTap = onEditTap
    self.onDeleteTap = onDeleteTap
  }
  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        OverflowPopupView(
          onEditTap: self.onEditTap,
          onDeleteTap: self.onDeleteTap
        )
      }
      
      BikeTypeView(
        type: bike.type,
        showTypeDescription: false,
        wheelSize: .constant(bike.wheelSize),
        bikeColor: .constant(Theme.BikeColor(rawValue: bike.color) ?? .bikeWhite)
      )
      
      HStack {
        VStack(alignment: .leading) {
          Text(bike.name)
            .font(.bikeNameFont)
          
          Text("\(Localization.wheels)\(bike.wheelSize.description)")
            .font(.textFont)
          
          HStack(spacing: 0) {
            Text(Localization.serviceIn)
              .font(.textFont)
            Text("\(bike.formattedServiceDue)")
              .font(.bikeServiceDueFont)
          }
        }
        .foregroundColor(.white)
        
        Spacer()
      }
      
      Spacer()
      
      BikeServiceProgressView(percentage: bike.serviceDuePercentage)
    }
    .padding()
    .frame(
      width: UIScreen.main.bounds.width - 10,
      height: (UIScreen.main.bounds.width - 10) * 0.9,
      alignment: .center
    )
    .background(
      ZStack {
        Theme.AppColor.appDarkBlue.value
        WaveShape(background: false)
          .fill(Theme.AppColor.appNavy.value)
      }
    )
    .cornerRadius(6)
    .onTapGesture {
      onTapGesture()
    }
  }
}

struct BikeCardView_Previews: PreviewProvider {
  static var previews: some View {
    BikeCardView(
      bike: Bike(
        id: UUID(),
        type: .electric,
        name: "Electric",
        color: "bikePink",
        wheelSize: .big,
        serviceDue: 100,
        isDefault: true
      ),
      onTapGesture: {},
      onEditTap: {},
      onDeleteTap: {}
    )
  }
}
