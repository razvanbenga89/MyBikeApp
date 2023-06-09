//
//  OverflowPopupView.swift
//  
//
//  Created by Razvan Benga on 05.06.2023.
//

import SwiftUI
import Popovers

public struct OverflowPopupView: View {
  @State private var isShowingPopover = false
  
  private let onEditTap: () -> Void
  private let onDeleteTap: () -> Void
  
  public init(
    onEditTap: @escaping () -> Void,
    onDeleteTap: @escaping () -> Void
  ) {
    self.onEditTap = onEditTap
    self.onDeleteTap = onDeleteTap
  }
  
  public var body: some View {
    Button {
      self.isShowingPopover = true
    } label: {
      Theme.Image.overflowIcon.value
    }
    .popover(present: $isShowingPopover) {
      Templates.Container(
        arrowSide: .top(.mostClockwise),
        backgroundColor: Theme.AppColor.appGreyBlue.value,
        padding: 0
      ) {
        VStack(alignment: .leading, spacing: 10) {
          Button {
            self.isShowingPopover = false
            self.onEditTap()
          } label: {
            HStack {
              Theme.Image.editIcon.value
              Text("Edit")
            }
          }
          
          Button {
            self.isShowingPopover = false
            self.onDeleteTap()
          } label: {
            HStack {
              Theme.Image.deleteIcon.value
              Text("Delete")
            }
          }
        }
        .font(.buttonFont)
        .foregroundColor(.white)
        .frame(width: 100, height: 80)
        .background(Theme.AppColor.appGreyBlue.value)
      }
    }
  }
}
