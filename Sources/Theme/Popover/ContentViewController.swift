//
//  ContentViewController.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import SwiftUI

class ContentViewController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V: View {
  var isPresented: Binding<Bool>
  
  init(rootView: V, isPresented: Binding<Bool>) {
    self.isPresented = isPresented
    super.init(rootView: rootView)
  }
  
  @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
    preferredContentSize = size
  }
  
  func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    .none
  }
  
  func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    self.isPresented.wrappedValue = false
  }
}
