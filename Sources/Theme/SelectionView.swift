//
//  SelectionView.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import SwiftUI
import PopupView

public struct SelectionView<T: Identifiable & CustomStringConvertible, Content: View>: View {
  @State private var isShowingPopover = false
  @Binding private var selectedValue: T?
  @Binding private var values: [T]
  @Binding private var isTextValid: Bool
  private var errorText: String?
  private var isRequired: Bool
  private var placeholder: String?
  private let contentBuilder: (T, Binding<Bool>) -> Content
  
  public init(
    selectedValue: Binding<T?>,
    values: Binding<[T]>,
    isRequired: Bool,
    placeholder: String?,
    isTextValid: Binding<Bool> = .constant(true),
    errorText: String? = nil,
    @ViewBuilder contentBuilder: @escaping (T, Binding<Bool>) -> Content
  ) {
    self._selectedValue = selectedValue
    self._values = values
    self.isRequired = isRequired
    self.placeholder = placeholder
    self._isTextValid = isTextValid
    self.errorText = errorText
    self.contentBuilder = contentBuilder
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      if let placeholder = self.placeholder {
        HStack(spacing: 0) {
          Text(placeholder)
            .font(.textFieldPlaceholderFont)
          
          if isRequired {
            Theme.Image.requiredIcon.value
          }
        }
        .foregroundColor(Theme.AppColor.appGrey.value)
      }
      
      HStack(alignment: .center) {
        if let selectedValue = self.selectedValue {
          Text(selectedValue.description)
        }
        
        Spacer()
        
        Button {
          self.isShowingPopover = true
        } label: {
          Theme.Image.dropDownIcon.value
            .padding(.top, 6)
            .opacity(values.count > 1 ? 1 : 0.5)
        }
        .disabled(values.count <= 1)
        .alwaysPopover(isPresented: $isShowingPopover) {
          VStack(spacing: 0) {
            ForEach(values, id: \.id) { value in
              self.contentBuilder(value, self.$isShowingPopover)
            }
          }
          .background(Theme.AppColor.appGreyBlue.value)
        }
      }
      .customTextField($selectedValue.isPresent())
      
      if !isTextValid, let errorText = self.errorText {
        Text(errorText)
          .foregroundColor(.red)
          .font(.textFieldPlaceholderFont)
      }
    }
    .animation(.easeInOut, value: isTextValid)
  }
}
