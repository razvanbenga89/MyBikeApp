//
//  AlwaysPopoverModifier.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import SwiftUI
import UIKit

class AnchorView: UIView, ObservableObject {}

struct AlwaysPopoverModifier<PopoverContent>: ViewModifier, Equatable where PopoverContent: View {
  static func == (lhs: AlwaysPopoverModifier<PopoverContent>, rhs: AlwaysPopoverModifier<PopoverContent>) -> Bool {
    lhs.isPresented == rhs.isPresented
  }
  
  @Binding var isPresented: Bool
  @StateObject var anchorView = AnchorView()
  
  let contentBlock: () -> PopoverContent
  
  func body(content: Content) -> some View {
    if isPresented {
      presentPopover()
    } else {
      dismissPopover()
    }
    
    return content
      .background(InternalAnchorView(uiView: anchorView))
  }
  
  private func presentPopover() {
    let contentController = ContentViewController(rootView: contentBlock(), isPresented: $isPresented)
    contentController.modalPresentationStyle = .popover
    
    let view = anchorView
    guard let popover = contentController.popoverPresentationController else { return }
    popover.sourceView = view
    popover.sourceRect = view.bounds
    popover.permittedArrowDirections = .any
    popover.delegate = contentController
    
    guard let sourceVC = view.closestVC() else { return }
    if let presentedVC = sourceVC.presentedViewController {
      presentedVC.dismiss(animated: true) {
        sourceVC.present(contentController, animated: true)
      }
    } else {
      sourceVC.present(contentController, animated: true)
    }
  }
  
  private func dismissPopover() {
    let view = anchorView
    guard let sourceVC = view.closestVC() else { return }
    
    if let presentedVC = sourceVC.presentedViewController {
      presentedVC.dismiss(animated: true)
    }
  }
  
  private struct InternalAnchorView: UIViewRepresentable {
    typealias UIViewType = UIView
    let uiView: UIView
    
    func makeUIView(context: Self.Context) -> Self.UIViewType {
      uiView
    }
    
    func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
  }
}
