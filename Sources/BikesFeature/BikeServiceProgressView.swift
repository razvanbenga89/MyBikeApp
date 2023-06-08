//
//  BikeServiceProgressView.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import SwiftUI
import Theme

struct BikeServiceProgressView: View {
  private let percentage: Double
  
  init(percentage: Double) {
    self.percentage = percentage
  }
  
  var body: some View {
    HStack(spacing: -1) {
      Theme.Image.loadingCircleIcon.value
      
      GeometryReader { proxy in
        ZStack(alignment: .leading) {
          Rectangle()
            .foregroundColor(Theme.AppColor.appGreyBlue.value)
            .frame(height: 5)
          
          Rectangle()
            .foregroundColor(Theme.AppColor.appLightBlue.value)
            .frame(width: calculateProgress(proxy: proxy), height: 5)
          
          Theme.Image.loadingWrenchIcon.value
            .offset(x: adjustWhenchIconOffset(proxy: proxy))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .frame(height: 22)
      
      Theme.Image.loadingBoltIcon.value
    }
    .frame(maxWidth: .infinity)
  }
  
  private func calculateProgress(proxy: GeometryProxy) -> CGFloat {
    min(proxy.size.width, percentage * proxy.size.width)
  }
  
  private func adjustWhenchIconOffset(proxy: GeometryProxy) -> CGFloat {
    let offset = calculateProgress(proxy: proxy)
    
    if offset >= proxy.size.width {
      return proxy.size.width - 8
    } else {
      return offset
    }
  }
}
