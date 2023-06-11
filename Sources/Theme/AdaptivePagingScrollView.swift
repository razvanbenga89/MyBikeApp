//
//  AdaptivePagingScrollView.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import SwiftUI

public struct AdaptivePagingScrollView: View {
  private let items: [AnyView]
  private let itemPadding: CGFloat
  private let itemSpacing: CGFloat
  private let itemWidth: CGFloat
  private let maxIndex: Int
  private let contentWidth: CGFloat
  
  private let leadingOffset: CGFloat
  private let scrollDampingFactor: CGFloat = 0.66
  
  @Binding var currentPageIndex: Int
  @State private var currentScrollOffset: CGFloat = 0
  @State private var gestureDragOffset: CGFloat = 0
  
  public init<A: View>(
    currentPageIndex: Binding<Int>,
    maxIndex: Int,
    itemWidth: CGFloat,
    itemPadding: CGFloat,
    pageWidth: CGFloat,
    @ViewBuilder content: () -> A
  ) {
    let views = content()
    self.items = [AnyView(views)]
    
    self._currentPageIndex = currentPageIndex
    
    self.maxIndex = maxIndex
    self.itemSpacing = itemPadding
    self.itemWidth = itemWidth
    self.itemPadding = itemPadding
    self.contentWidth = (itemWidth + itemPadding) * CGFloat(maxIndex)
    
    let itemRemain = (pageWidth - itemWidth - 2 * itemPadding) / 2
    self.leadingOffset = itemRemain + itemPadding
  }
  
  private func countOffset(for pageIndex: Int) -> CGFloat {
    let activePageOffset = CGFloat(pageIndex) * (itemWidth + itemPadding)
    return leadingOffset - activePageOffset
  }
  
  private func countPageIndex(for offset: CGFloat) -> Int {
    guard maxIndex > 0 else { return 0 }
    
    let offset = countLogicalOffset(offset)
    let floatIndex = (offset) / (itemWidth + itemPadding)
    var index = Int(round(floatIndex))
    
    if max(index, 0) > maxIndex {
      index = maxIndex
    }
    
    return max(index, 0)
  }
  
  private func countCurrentScrollOffset() -> CGFloat {
    countOffset(for: currentPageIndex) + gestureDragOffset
  }
  
  private func countLogicalOffset(_ trueOffset: CGFloat) -> CGFloat {
    (trueOffset-leadingOffset) * -1.0
  }
  
  public var body: some View {
    GeometryReader { viewGeometry in
      HStack(alignment: .center, spacing: itemSpacing) {
        ForEach(items.indices, id: \.self) { itemIndex in
          items[itemIndex]
            .frame(width: itemWidth)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .onAppear {
      currentScrollOffset = countOffset(for: currentPageIndex)
    }
    .frame(width: contentWidth)
    .offset(x: self.currentScrollOffset, y: 0)
    .simultaneousGesture(
      DragGesture(minimumDistance: 1, coordinateSpace: .local)
        .onChanged { value in
          gestureDragOffset = value.translation.width
          currentScrollOffset = countCurrentScrollOffset()
        }
        .onEnded { value in
          let cleanOffset = (value.predictedEndTranslation.width - gestureDragOffset)
          let velocityDiff = cleanOffset * scrollDampingFactor
          
          var newPageIndex = countPageIndex(for: currentScrollOffset + velocityDiff)
          
          let currentItemOffset = CGFloat(currentPageIndex) * (itemWidth + itemPadding)
          
          if currentScrollOffset < -(currentItemOffset),
             newPageIndex == currentPageIndex {
            newPageIndex = min(newPageIndex + 1, maxIndex)
          }
          
          gestureDragOffset = 0
          withAnimation(.interpolatingSpring(mass: 0.1,
                                             stiffness: 20,
                                             damping: 1.5,
                                             initialVelocity: 0)) {
            self.currentPageIndex = newPageIndex
            self.currentScrollOffset = self.countCurrentScrollOffset()
          }
        }
    )
  }
}
