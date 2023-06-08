//
//  CustomTextField.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import Foundation
import SwiftUI

public struct CustomTextField: View {
  @Binding private var text: String
  @Binding private var isTextValid: Bool
  private var isRequired: Bool
  private var placeholder: String?
  private var errorText: String?
  private var tips: String?
  private var onChangeText: ((String) -> Void)?
  
  public init(
    text: Binding<String>,
    isRequired: Bool = true,
    isTextValid: Binding<Bool> = .constant(true),
    onChangeText: ((String) -> Void)? = nil,
    placeholder: String? = nil,
    errorText: String? = nil,
    tips: String? = nil
  ) {
    self.placeholder = placeholder
    self.isRequired = isRequired
    self._text = text
    self._isTextValid = isTextValid
    self.errorText = errorText
    self.onChangeText = onChangeText
    self.tips = tips
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
      
      HStack {
        TextField("", text: $text)
          .onChange(of: text) { newValue in
            self.isTextValid = true
            onChangeText?(newValue)
          }
          
        if let tips = tips {
          Text(tips)
            .foregroundColor(Theme.AppColor.appGrey.value)
        }
      }
      .customTextField($isTextValid)
      
      if !isTextValid, let errorText = self.errorText {
        Text(errorText)
          .foregroundColor(.red)
          .font(.textFieldPlaceholderFont)
      }
    }
    .animation(.easeInOut, value: isTextValid)
  }
}
