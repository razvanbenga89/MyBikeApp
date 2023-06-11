//
//  RideDatePickerView.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import SwiftUI
import Theme
import Popovers
import Localization

struct RideDatePickerView: View {
  @Binding var formattedDate: String
  @Binding var selectedDate: Date?
  @Binding var isFieldValid: Bool
  @State var isShowingPopover: Bool = false
  private let onTapGesture: () -> Void
  
  init(
    formattedDate: Binding<String>,
    selectedDate: Binding<Date?>,
    isFieldValid: Binding<Bool>,
    onTapGesture: @escaping () -> Void
  ) {
    self._formattedDate = formattedDate
    self._selectedDate = selectedDate
    self._isFieldValid = isFieldValid
    self.onTapGesture = onTapGesture
  }
  
  var body: some View {
    CustomTextField(
      text: $formattedDate,
      isTextValid: $isFieldValid,
      placeholder: Localization.datePlaceholder,
      errorText: Localization.requiredFieldMessage
    )
    .disabled(true)
    .onTapGesture {
      isFieldValid = true
      isShowingPopover = true
      onTapGesture()
    }
    .popover(present: $isShowingPopover, attributes: {
      $0.rubberBandingMode = .none
      $0.position = .absolute(
        originAnchor: .top,
        popoverAnchor: .bottom
      )
    }) {
      Templates.Container(
        backgroundColor: Theme.AppColor.appGreyBlue.value,
        padding: 0
      ) {
        DatePickerView(selectedDate: $selectedDate) {
          isShowingPopover = false
        }
      }
    }
  }
}

struct RideDatePickerView_Previews: PreviewProvider {
  static var previews: some View {
    RideDatePickerView(
      formattedDate: .constant(""),
      selectedDate: .constant(Date()),
      isFieldValid: .constant(true),
      onTapGesture: {}
    )
  }
}
