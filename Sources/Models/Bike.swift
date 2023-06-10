//
//  Bike.swift
//  
//
//  Created by Razvan Benga on 01.06.2023.
//

import Foundation

public enum BikeType: Int, CaseIterable, Identifiable {
  public var id: Self {
    self
  }
  
  case mtb = 1
  case road = 2
  case electric = 3
  case hybrid = 4
}

public enum WheelSize: Int, CaseIterable, Identifiable {
  public var id: Self {
    self
  }
  
  case big = 1
  case small = 2
}

public enum DistanceUnit: String, CaseIterable, Identifiable {
  public var id: Self {
    self
  }
  
  case km = "KM"
  case mi = "MI"
  
  public var unitLength: UnitLength {
    switch self {
    case .mi:
      return .miles
    case .km:
      return .kilometers
    }
  }
  
  public var toggledUnitLength: UnitLength {
    switch self {
    case .mi:
      return .kilometers
    case .km:
      return .miles
    }
  }
}

public struct Bike: Identifiable {
  public let id: UUID
  public let type: BikeType
  public let name: String
  public let color: String
  public let wheelSize: WheelSize
  public let serviceDue: Double
  public let isDefault: Bool
  public var rides: [Ride] = []
  
  public var ridesTotalDistance: Double {
    rides.reduce(0) { total, ride in
      total + ride.distance
    }
  }
  
  public init(
    id: UUID,
    type: BikeType,
    name: String,
    color: String,
    wheelSize: WheelSize,
    serviceDue: Double,
    isDefault: Bool,
    rides: [Ride] = []
  ) {
    self.id = id
    self.type = type
    self.name = name
    self.color = color
    self.wheelSize = wheelSize
    self.serviceDue = serviceDue
    self.isDefault = isDefault
    self.rides = rides
  }
}

extension Bike {
  public static var mock: Bike {
    let bikeId = UUID()
    let bikeName = "MTB"
    
    let rides = Ride.buildMocks(bikeId: bikeId, bikeName: bikeName)
    
    return Bike(
      id: bikeId,
      type: .mtb,
      name: bikeName,
      color: "bikeOrange",
      wheelSize: .small,
      serviceDue: 100,
      isDefault: false,
      rides: rides
    )
  }
  
  public static var mocks: [Bike] {
    BikeType.allCases
      .compactMap { bikeType in
        let bikeId = UUID()
        
        switch bikeType {
        case .electric:
          return Bike(
            id: bikeId,
            type: bikeType,
            name: "ELECTRIC",
            color: "bikeRed",
            wheelSize: .big,
            serviceDue: 100,
            isDefault: false,
            rides: []
          )
        case .mtb:
          return Bike.mock
        case .road:
          return Bike(
            id: bikeId,
            type: bikeType,
            name: "ROAD",
            color: "bikeWhite",
            wheelSize: .small,
            serviceDue: 100,
            isDefault: false,
            rides: [
              Ride(
                id: UUID(),
                name: "City ride",
                distance: 45,
                duration: 180,
                date: Date(),
                bikeId: bikeId,
                bikeName: "ROAD"
              )
            ]
          )
        case .hybrid:
          return Bike(
            id: bikeId,
            type: bikeType,
            name: "Hybrid",
            color: "bikeRed",
            wheelSize: .big,
            serviceDue: 100,
            isDefault: false,
            rides: (1..<5).map { val in
              Ride(
                id: UUID(),
                name: "City ride \(val)",
                distance: 300,
                duration: 180,
                date: Date(),
                bikeId: bikeId,
                bikeName: "Hybrid"
              )
            }
          )
        }
      }
  }
}

extension Bike: CustomStringConvertible {
  public var description: String {
    name
  }
}

extension DistanceUnit: CustomStringConvertible {
  public var description: String {
    rawValue
  }
}
