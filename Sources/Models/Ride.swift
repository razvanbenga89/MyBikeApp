//
//  Ride.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import Foundation

public struct Ride: Identifiable {
  public let id: UUID
  public let name: String
  public let distance: Double
  public let duration: Int
  public let date: Date
  public let bikeId: UUID
  public let bikeName: String
  public let bikeType: BikeType
  
  public init(
    id: UUID,
    name: String,
    distance: Double,
    duration: Int,
    date: Date,
    bikeId: UUID,
    bikeName: String,
    bikeType: BikeType = .mtb
  ) {
    self.id = id
    self.name = name
    self.distance = distance
    self.duration = duration
    self.date = date
    self.bikeId = bikeId
    self.bikeName = bikeName
    self.bikeType = bikeType
  }
}

extension Ride {
  public static var mock: Ride {
    Ride(
      id: UUID(),
      name: "Faget Tour",
      distance: 45,
      duration: 200,
      date: Date(),
      bikeId: UUID(),
      bikeName: "Radon"
    )
  }
  
  public static func buildMocks(bikeId: UUID, bikeName: String) -> [Ride] {
    [
      Ride(
        id: UUID(),
        name: "Faget Tour",
        distance: 45,
        duration: 180,
        date: Date(),
        bikeId: bikeId,
        bikeName: bikeName
      ),
      Ride(
        id: UUID(),
        name: "Avrig Tour",
        distance: 65,
        duration: 240,
        date: Date(),
        bikeId: bikeId,
        bikeName: bikeName
      ),
      Ride(
        id: UUID(),
        name: "City Ride",
        distance: 10,
        duration: 20,
        date: Date(),
        bikeId: bikeId,
        bikeName: bikeName
      )
    ]
  }
}
