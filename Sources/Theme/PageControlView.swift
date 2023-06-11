//
//  PageControlView.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import SwiftUI

public struct PageControlView: View {
  @Binding private var currentPageIndex: Int
  private let totalNumberOfPages: Int
  
  public init(
    currentPageIndex: Binding<Int>,
    totalNumberOfPages: Int
  ) {
    self._currentPageIndex = currentPageIndex
    self.totalNumberOfPages = totalNumberOfPages
  }
  
  public var body: some View {
    ZStack {
      Capsule()
        .foregroundColor(.black)
      
      HStack(spacing: 8) {
        ForEach(0..<totalNumberOfPages, id: \.self) { pageNumber in
          Circle()
            .foregroundColor(
              pageNumber == currentPageIndex ? .blue : .white
            )
            .frame(width: 8, height: 8)
        }
      }
    }
    .frame(
      width: CGFloat(totalNumberOfPages * 8) + CGFloat((totalNumberOfPages + 1) * 8),
      height: 20
    )
  }
}
