//
//  DatePickerView.swift
//  
//
//  Created by Razvan Benga on 11.06.2023.
//

import SwiftUI
import Localization

public struct DatePickerView: View {
  @Binding private var selectedDate: Date?
  @State private var date = Date()
  private var title: String?
  private let didTapSave: () -> Void
  
  public init(
    selectedDate: Binding<Date?>,
    title: String? = nil,
    didTapSave: @escaping () -> Void
  ) {
    self._selectedDate = selectedDate
    self.title = title
    self.didTapSave = didTapSave
    if let selectedDate = selectedDate.wrappedValue {
      self.date = selectedDate
    }
  }
  
  public var body: some View {
    VStack {
      if let title = title {
        Text(title)
          .font(.textFont)
          .foregroundColor(.white)
      }
      
      DatePicker("", selection: $date, displayedComponents: .date)
        .datePickerStyle(.graphical)
        .labelsHidden()
        .scaleEffect(x: 0.9, y: 0.9, anchor: .center)
      
      Button {
        self.selectedDate = self.date
        didTapSave()
      } label: {
        Text(Localization.saveAction)
      }
      .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
    .background(Theme.AppColor.appGreyBlue.value)
  }
}
