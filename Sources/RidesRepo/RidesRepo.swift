//
//  RidesRepo.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import Foundation
import Dependencies
import Models
import XCTestDynamicOverlay

public struct RidesRepo {
  public var getRides: @Sendable () -> AsyncStream<[Ride]>
  public var addNewRide: @Sendable (Ride) async throws -> Void
  public var updateRide: @Sendable (Ride) async throws -> Void
  public var deleteRide: @Sendable (UUID) async throws -> Void
  
  public init(
    getRides: @escaping @Sendable () -> AsyncStream<[Ride]>,
    addNewRide: @escaping @Sendable (Ride) async throws -> Void,
    updateRide: @escaping @Sendable (Ride) async throws -> Void,
    deleteRide: @escaping @Sendable (UUID) async throws -> Void
  ) {
    self.getRides = getRides
    self.addNewRide = addNewRide
    self.updateRide = updateRide
    self.deleteRide = deleteRide
  }
}

extension RidesRepo: TestDependencyKey {
  public static let testValue = Self(
    getRides: unimplemented("\(Self.self).getRides"),
    addNewRide: unimplemented("\(Self.self).addNewRide"),
    updateRide: unimplemented("\(Self.self).updateRide"),
    deleteRide: unimplemented("\(Self.self).deleteRide")
  )
  
  public static let previewValue = Self(
    getRides: {
      AsyncStream { continuation in
        let bikeId = UUID()
        continuation.yield(Ride.buildMocks(bikeId: bikeId, bikeName: "Radon"))
        continuation.finish()
      }
    },
    addNewRide: { _ in },
    updateRide: { _ in },
    deleteRide: { _ in }
  )
}

extension DependencyValues {
  public var ridesRepo: RidesRepo {
    get { self[RidesRepo.self] }
    set { self[RidesRepo.self] = newValue }
  }
}
