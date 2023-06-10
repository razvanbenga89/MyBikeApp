//
//  ServiceReminderPickerView.swift
//  
//
//  Created by Razvan Benga on 09.06.2023.
//

import SwiftUI
import Theme
import Popovers

struct ServiceReminderPickerView: View {
  @State var isShowingPopover: Bool = false
  @State private var selectedValue: Int
  @Binding private var selectedServiceReminder: String
  private let description: String
  private let didTapSave: (Int) -> Void
  
  init(
    selectedServiceReminder: Binding<String>,
    description: String,
    didTapSave: @escaping (Int) -> Void
  ) {
    self._selectedServiceReminder = selectedServiceReminder
    self.selectedValue = Int(selectedServiceReminder.wrappedValue) ?? 100
    self.description = description
    self.didTapSave = didTapSave
  }
  
  var body: some View {
    CustomTextField(
      text: self.$selectedServiceReminder,
      isRequired: false,
      description: self.description
    )
    .disabled(true)
    .onTapGesture {
      isShowingPopover = true
    }
    .popover(present: $isShowingPopover, attributes: {
      $0.rubberBandingMode = .none
    }) {
      Templates.Container(
        backgroundColor: Theme.AppColor.appGreyBlue.value,
        padding: 0
      ) {
        VStack {
          Picker("", selection: self.$selectedValue) {
            ForEach(
              Array(
                stride(
                  from: 100,
                  to: 1100,
                  by: 100
                )
              ),
              id: \.self
            ) {
              Text(String($0))
                .tag($0)
            }
          }
          .pickerStyle(.wheel)
          .font(.textFont)
          
          Button {
            isShowingPopover = false
            self.didTapSave(selectedValue)
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
}

struct ServiceReminderPickerView_Previews: PreviewProvider {
  static var previews: some View {
    ServiceReminderPickerView(
      selectedServiceReminder: .constant("100"),
      description: "KM",
      didTapSave: { _ in }
    )
  }
}
