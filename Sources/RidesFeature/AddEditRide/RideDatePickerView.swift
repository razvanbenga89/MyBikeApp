//
//  RideDatePickerView.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import SwiftUI
import Theme

struct RideDatePickerView: View {
  @Binding var formattedDate: String
  @Binding var selectedDate: Date
  @Binding var isFieldValid: Bool
  @State var isShowingPopover: Bool = false
  @State private var date = Date()
  
  init(
    formattedDate: Binding<String>,
    selectedDate: Binding<Date>,
    isFieldValid: Binding<Bool>
  ) {
    self._formattedDate = formattedDate
    self._selectedDate = selectedDate
    self._isFieldValid = isFieldValid
    self.date = selectedDate.wrappedValue
  }
  
  var body: some View {
    CustomTextField(
      text: $formattedDate,
      isTextValid: $isFieldValid,
      placeholder: "Date",
      errorText: "Required Field"
    )
    .disabled(true)
    .onTapGesture {
      isFieldValid = true
      isShowingPopover = true
    }
    .alwaysPopover(isPresented: $isShowingPopover) {
      VStack {
        GeometryReader { proxy in
          DatePicker("", selection: $date, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .labelsHidden()
            .scaleEffect(x: 0.9, y: 0.9, anchor: .center)
            .frame(maxWidth: .infinity, maxHeight: proxy.size.height)
        }
        
        Button {
          isShowingPopover = false
          self.selectedDate = self.date
        } label: {
          Text("Save")
        }
        .buttonStyle(PrimaryButtonStyle())
      }
      .padding()
      .background(Theme.AppColor.appGreyBlue.value)
    }
  }
}

struct RideDatePickerView_Previews: PreviewProvider {
  static var previews: some View {
    RideDatePickerView(
      formattedDate: .constant(""),
      selectedDate: .constant(Date()),
      isFieldValid: .constant(true)
    )
  }
}
