//
//  ViewExtensions.swift
//  
//
//  Created by Razvan Benga on 30.05.2023.
//

import SwiftUI
import Popovers
import SwiftUINavigation

public extension View {
  @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
    if isHidden {
      self.hidden()
    } else {
      self
    }
  }
  
  func customTextField(_ isTextValid: Binding<Bool> = .constant(true)) -> some View {
    modifier(CustomTextFieldModifier(isTextValid: isTextValid))
  }
  
  func viewDidLoadTask(_ action: @escaping @Sendable () async -> Void) -> some View {
    modifier(ViewDidLoadTaskModifier(perform: action))
  }
  
  func alertView<Enum, Value>(
    unwrapping `enum`: Binding<Enum?>,
    case casePath: CasePath<Enum, AlertViewState<Value>>,
    action handler: @escaping (Value?) -> Void = { (_: Never?) in }
  ) -> some View {
    alertView(unwrapping: `enum`.case(casePath), action: handler)
  }
  
  func alertView<Value>(
    unwrapping value: Binding<AlertViewState<Value>?>,
    action handler: @escaping (Value?) -> Void = { (_: Never?) in }
  ) -> some View {
    popover(present: value.isPresent(), attributes: {
      $0.blocksBackgroundTouches = true
      $0.rubberBandingMode = .none
      $0.position = .relative(
        popoverAnchors: [
          .center,
        ]
      )
      $0.presentation.animation = .easeOut(duration: 0.2)
      $0.dismissal.mode = .none
    }) {
      AlertView(
        isShown: value.isPresent(),
        alertViewState: value.wrappedValue,
        handler: handler
      )
    } background: {
      Color.black.opacity(0.5)
    }
  }
}

public enum AlertActionStyle {
  case cancel
  case destructive
}

public struct AlertActionState<Action>: Identifiable {
  public let id: UUID
  public let title: String
  public let style: AlertActionStyle
  public let actionType: Action?
  public let didTap: () -> Void
  
  public init(
    id: UUID = UUID(),
    title: String,
    style: AlertActionStyle = .cancel,
    actionType: Action? = nil,
    didTap: @escaping () -> Void = {}
  ) {
    self.id = id
    self.title = title
    self.style = style
    self.actionType = actionType
    self.didTap = didTap
  }
}

public struct AlertViewState<Action> {
  public let title: String
  public var message: String?
  public let actions: [AlertActionState<Action>]
  
  public init(
    title: String,
    message: String? = nil,
    actions: [AlertActionState<Action>] = []
  ) {
    self.title = title
    self.message = message
    self.actions = actions
  }
}

struct AlertView<Action>: View {
  @Binding private var isShown: Bool
  private var alertViewState: AlertViewState<Action>?
  private let handler: (Action?) -> Void
  
  init(
    isShown: Binding<Bool>,
    alertViewState: AlertViewState<Action>? = nil,
    handler: @escaping (Action?) -> Void = { (_: Never?) in }
  ) {
    self._isShown = isShown
    self.alertViewState = alertViewState
    self.handler = handler
  }
  
  var body: some View {
    if let alertViewState = alertViewState {
      VStack(spacing: 0) {
        Spacer()
        
        VStack {
          Text(alertViewState.title)
            .font(.alertTitleFont)
          
          if let message = alertViewState.message {
            Text(message)
              .font(.alertMessageFont)
          }
        }
        .padding(.bottom)
        
        Spacer()
        
        if alertViewState.actions.isEmpty {
          Button {
            self.isShown = false
          } label: {
            Text("Ok")
          }
          .font(.buttonFont)
        } else {
          LazyHStack(spacing: 20) {
            ForEach(alertViewState.actions) { action in
              switch action.style {
              case .cancel:
                Button {
                  self.handler(action.actionType)
                } label: {
                  Text(action.title)
                }
              case .destructive:
                Button {
                  self.handler(action.actionType)
                } label: {
                  Text(action.title)
                }
                .buttonStyle(PrimaryButtonStyle())
              }
            }
          }
          .frame(height: 40)
          .font(.buttonFont)
        }
        
        Spacer()
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding()
      .frame(
        width: UIScreen.main.bounds.width - 40,
        height: (UIScreen.main.bounds.width - 40) / 2
      )
      .background(Theme.AppColor.appNavy.value)
      .cornerRadius(5)
    }
  }
}

public struct CustomTextFieldModifier: ViewModifier {
  @Binding private var isTextValid: Bool
  
  public init(isTextValid: Binding<Bool>) {
    self._isTextValid = isTextValid
  }
  
  public func body(content: Content) -> some View {
    content
      .foregroundColor(.white)
      .font(.textFieldFont)
      .padding()
      .frame(height: 40)
      .background(Theme.AppColor.appNavy.value)
      .cornerRadius(6)
      .overlay {
        RoundedRectangle(cornerRadius: 6)
          .stroke(isTextValid ? .white : .red, lineWidth: 1)
      }
  }
}

public struct PrimaryButtonStyle: ButtonStyle {
  @Environment(\.isEnabled) var isEnabled
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .font(.buttonFont)
      .padding()
      .frame(height: 40)
      .frame(maxWidth: .infinity)
      .foregroundColor(Theme.AppColor.appWhite.value)
      .background(Theme.AppColor.appLightBlue.value)
      .cornerRadius(5)
      .opacity(isEnabled ? 1 : 0.5)
  }
}

struct ViewDidLoadTaskModifier: ViewModifier {
  @State private var didLoad = true
  private let action: @Sendable () async -> Void
  
  init(perform action: @escaping @Sendable () async -> Void) {
    self.action = action
  }
  
  func body(content: Content) -> some View {
    content.task(id: didLoad) {
      await action()
    }
  }
}

struct TestView: View {
  var body: some View {
    CustomTextField(
      text: .constant(""),
      isRequired: true,
      isTextValid: .constant(true),
      placeholder: "Bike name",
      errorText: "Required field"
    )
    .padding(.vertical, 10)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.defaultBackgroundColor)
  }
}

struct ViewExtensions_Previews: PreviewProvider {
  static var previews: some View {
    TestView()
      .background(Color.defaultBackgroundColor)
  }
}
