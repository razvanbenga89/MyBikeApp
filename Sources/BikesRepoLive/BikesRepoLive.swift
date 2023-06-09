//
//  BikesRepoLive.swift
//  
//
//  Created by Razvan Benga on 02.06.2023.
//

import Foundation
import Storage
import Models
import BikesRepo
import Dependencies

extension BikesRepo: DependencyKey {
  public static var liveValue: Self {
    let bikesDatabaseService = BikesDatabaseService()
    
    return Self(
      getBikes: {
        AsyncStream { continuation in
          let task = Task {
            for await value in await bikesDatabaseService.fetchBikes() {
              continuation.yield(value.compactMap(Bike.init))
            }
          }
          
          continuation.onTermination = { _ in
            task.cancel()
          }
        }
      },
      getBike: { uuid in
        do {
          let bikeEntity = try await bikesDatabaseService.fetchBike(id: uuid)
          
          if let bike = Bike(entity: bikeEntity) {
            return bike
          } else {
            throw "Failed building data"
          }
        } catch DBError.entityNotFound {
          throw "Failed getting bike"
        }
      },
      addNewBike: { bike in
        try await bikesDatabaseService.addNewBike(bike: bike)
      },
      updateBike: { bike in
        try await bikesDatabaseService.updateBike(bike: bike)
      },
      deleteBike: { id in
        try await bikesDatabaseService.deleteBike(id: id)
      }
    )
  }
}
