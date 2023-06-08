//
//  ColorSelectionView.swift
//  
//
//  Created by Razvan Benga on 05.06.2023.
//

import SwiftUI
import Theme

struct ColorSelectionView: View {
  private let bikeColors: [Theme.BikeColor]
  @Binding private var selectedBikeColor: Theme.BikeColor
  
  init(
    bikeColors: [Theme.BikeColor],
    selectedBikeColor: Binding<Theme.BikeColor>
  ) {
    self.bikeColors = bikeColors
    self._selectedBikeColor = selectedBikeColor
  }
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack {
          ForEach(bikeColors, id: \.self) { bikeColor in
            Button(action: {
              self.selectedBikeColor = bikeColor
              withAnimation {
                proxy.scrollTo(bikeColor)
              }
            }) {
              Circle()
                .strokeBorder(
                  self.selectedBikeColor == bikeColor ? .white : .clear,
                  lineWidth: 2
                )
                .background(
                  Circle()
                    .fill(bikeColor.value)
                    .frame(width: 20, height: 20)
                )
                .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 5)
          }
        }
      }
    }
    .frame(height: 40)
  }
}
