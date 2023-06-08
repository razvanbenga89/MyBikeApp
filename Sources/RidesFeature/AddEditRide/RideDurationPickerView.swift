//
//  RideDurationPickerView.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import SwiftUI
import Theme

struct RideDurationPickerView: View {
  @Binding var duration: String
  @Binding var selectedHours: Int
  @Binding var selectedMinutes: Int
  @Binding var isFieldValid: Bool
  @State var isShowingPopover: Bool = false
  @State private var hours: Int
  @State private var minutes: Int
  
  init(
    duration: Binding<String>,
    selectedHours: Binding<Int>,
    selectedMinutes: Binding<Int>,
    isFieldValid: Binding<Bool>
  ) {
    self._duration = duration
    self._selectedHours = selectedHours
    self._selectedMinutes = selectedMinutes
    self._isFieldValid = isFieldValid
    self.hours = selectedHours.wrappedValue
    self.minutes = selectedMinutes.wrappedValue
  }
  
  var body: some View {
    CustomTextField(
      text: $duration,
      isTextValid: $isFieldValid,
      placeholder: "Duration",
      errorText: "Required Field"
    )
    .disabled(true)
    .onTapGesture {
      isFieldValid = true
      isShowingPopover = true
    }
    .alwaysPopover(isPresented: $isShowingPopover) {
      VStack {
        HStack(spacing: 0) {
          VStack {
            Text("Hours")
            
            Picker("", selection: $hours) {
              ForEach(0..<21) {
                Text(String($0))
                  .tag($0)
              }
            }
            .pickerStyle(.wheel)
          }
          
          VStack {
            Text("Minutes")
            
            Picker("", selection: $minutes) {
              ForEach(0..<60) {
                Text(String($0))
                  .tag($0)
              }
            }
            .pickerStyle(.wheel)
          }
        }
        .font(.textFont)
        
        Button {
          isShowingPopover = false
          self.selectedHours = self.hours
          self.selectedMinutes = self.minutes
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

struct RideDurationPickerView_Previews: PreviewProvider {
  static var previews: some View {
    RideDurationPickerView(
      duration: .constant(""),
      selectedHours: .constant(0),
      selectedMinutes: .constant(0),
      isFieldValid: .constant(true)
    )
  }
}
