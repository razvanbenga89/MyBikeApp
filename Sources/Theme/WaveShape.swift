//
//  WaveShape.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import SwiftUI

public struct WaveShape: Shape {
  private let background: Bool
  
  public init(background: Bool = true) {
    self.background = background
  }
  
  public func path(in rect: CGRect) -> Path {
    if background {
      return Path { path in
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.25))
        path.addCurve(
          to: CGPoint(x: rect.minX, y: rect.maxY * 0.31),
          control1: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.35),
          control2: CGPoint(x: rect.maxX / 2.5, y: rect.maxY * 0.18)
        )
        path.closeSubpath()
      }
    } else {
      return Path { path in
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.5))
        path.addCurve(
          to: CGPoint(x: rect.minX, y: rect.maxY * 0.65),
          control1: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.75),
          control2: CGPoint(x: rect.maxX / 2.5, y: rect.maxY * 0.35)
        )
        path.closeSubpath()
      }
    }
  }
}
