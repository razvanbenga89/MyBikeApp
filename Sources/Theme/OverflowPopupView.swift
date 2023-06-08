//
//  OverflowPopupView.swift
//  
//
//  Created by Razvan Benga on 05.06.2023.
//

import SwiftUI

public struct OverflowPopupView: View {
  @State private var isShowingPopover = false
  @Binding var isShowingPopup: Bool
  private let onEditTap: () -> Void
  private let onDeleteTap: () -> Void
  
  public init(
    isShowingPopup: Binding<Bool> = .constant(false),
    onEditTap: @escaping () -> Void,
    onDeleteTap: @escaping () -> Void
  ) {
    self._isShowingPopup = isShowingPopup
    self.onEditTap = onEditTap
    self.onDeleteTap = onDeleteTap
  }
  
  public var body: some View {
    Button {
      self.isShowingPopover = true
    } label: {
      Theme.Image.overflowIcon.value
    }
    .buttonStyle(PlainButtonStyle())
    .alwaysPopover(isPresented: $isShowingPopover) {
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
          self.isShowingPopup = false
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
