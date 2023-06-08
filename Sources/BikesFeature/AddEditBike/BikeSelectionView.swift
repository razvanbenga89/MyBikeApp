//
//  BikeSelectionView.swift
//  
//
//  Created by Razvan Benga on 05.06.2023.
//

import SwiftUI
import Theme
import Models

struct BikeSelectionView: View {
  private let bikeTypes: [BikeType]
  @Binding private var selectedBikeTypeIndex: Int
  @Binding private var selectedWheelSize: WheelSize
  @Binding private var selectedBikeColor: Theme.BikeColor
  
  init(
    bikeTypes: [BikeType],
    selectedBikeTypeIndex: Binding<Int>,
    selectedWheelSize: Binding<WheelSize>,
    selectedBikeColor: Binding<Theme.BikeColor>
  ) {
    self.bikeTypes = bikeTypes
    self._selectedBikeTypeIndex = selectedBikeTypeIndex
    self._selectedWheelSize = selectedWheelSize
    self._selectedBikeColor = selectedBikeColor
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      GeometryReader { geometry in
        AdaptivePagingScrollView(
          currentPageIndex: self.$selectedBikeTypeIndex,
          maxIndex: bikeTypes.count - 1,
          itemWidth: geometry.size.width * 0.66,
          itemPadding: 30,
          pageWidth: geometry.size.width
        ) {
          ForEach(bikeTypes, id: \.self) { bikeType in
            BikeTypeView(
              type: bikeType,
              showTypeDescription: true,
              wheelSize: self.$selectedWheelSize,
              bikeColor: self.$selectedBikeColor
            )
          }
        }
      }
      .frame(height: 200)
      
      PageControlView(
        currentPageIndex: self.$selectedBikeTypeIndex,
        totalNumberOfPages: bikeTypes.count
      )
    }
    .background(.clear)
  }
}
