//
//  UIViewExtensions.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import UIKit

extension UIView {
  func closestVC() -> UIViewController? {
    var responder: UIResponder? = self
    while responder != nil {
      if let vc = responder as? UIViewController {
        return vc
      }
      responder = responder?.next
    }
    return nil
  }
}
