//
//  RidesRepoLive.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import Foundation
import Storage
import Models
import RidesRepo
import Dependencies

extension RidesRepo: DependencyKey {
  public static var liveValue: Self {
    let ridesDatabaseService = RidesDatabaseService()
    
    return Self(
      getRides: {
        ridesDatabaseService.fetchRides()
          .map {
            $0.compactMap(Ride.init)
          }
          .eraseToStream()
      },
      addNewRide: { ride in
        try await ridesDatabaseService.addNewRide(ride: ride)
      },
      updateRide: { ride in
        try await ridesDatabaseService.updateRide(ride: ride)
      },
      deleteRide: { id in
        try await ridesDatabaseService.deleteRide(id: id)
      }
    )
  }
}
