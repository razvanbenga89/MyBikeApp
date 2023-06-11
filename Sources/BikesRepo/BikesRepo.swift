//
//  BikesRepo.swift
//  
//
//  Created by Razvan Benga on 01.06.2023.
//

import Foundation
import Dependencies
import Models
import XCTestDynamicOverlay

extension String: Error {}
extension String: LocalizedError {
  public var errorDescription: String? { self }
}

public struct BikesRepo {
  public var setup: @Sendable () async throws -> Void
  public var getBikes: @Sendable () -> AsyncStream<[Bike]>
  public var getBike: @Sendable (UUID) async throws -> Bike
  public var addNewBike: @Sendable (Bike) async throws -> Void
  public var updateBike: @Sendable (Bike) async throws -> Void
  public var updateBikeToDefault: @Sendable (UUID) async throws -> Void
  public var updateLatestService: @Sendable (UUID, Date) async throws -> Void
  public var deleteBike: @Sendable (UUID) async throws -> Void
  
  public init(
    setup: @escaping @Sendable () async throws -> Void,
    getBikes: @escaping @Sendable () -> AsyncStream<[Bike]>,
    getBike: @escaping @Sendable (UUID) async throws -> Bike,
    addNewBike: @escaping @Sendable (Bike) async throws -> Void,
    updateBike: @escaping @Sendable (Bike) async throws -> Void,
    updateBikeToDefault: @escaping @Sendable (UUID) async throws -> Void,
    updateLatestService: @escaping @Sendable (UUID, Date) async throws -> Void,
    deleteBike: @escaping @Sendable (UUID) async throws -> Void
  ) {
    self.setup = setup
    self.getBikes = getBikes
    self.getBike = getBike
    self.addNewBike = addNewBike
    self.updateBike = updateBike
    self.updateBikeToDefault = updateBikeToDefault
    self.updateLatestService = updateLatestService
    self.deleteBike = deleteBike
  }
}

extension BikesRepo: TestDependencyKey {
  public static let testValue = Self(
    setup: unimplemented("\(Self.self).setup"),
    getBikes: unimplemented("\(Self.self).getBikes"),
    getBike: unimplemented("\(Self.self).getBike"),
    addNewBike: unimplemented("\(Self.self).addNewBike"),
    updateBike: unimplemented("\(Self.self).updateBike"),
    updateBikeToDefault: unimplemented("\(Self.self).updateBikeToDefault"),
    updateLatestService: unimplemented("\(Self.self).updateLatestService"),
    deleteBike: unimplemented("\(Self.self).deleteBike")
  )
  
  public static let previewValue = Self(
    setup: {},
    getBikes: {
      AsyncStream { continuation in
        continuation.yield(Bike.mocks)
        continuation.finish()
      }
    },
    getBike: { _ in
      Bike.mock
    },
    addNewBike: { _ in },
    updateBike: { _ in },
    updateBikeToDefault: { _ in },
    updateLatestService: { _, _ in },
    deleteBike: { _ in }
  )
}

extension DependencyValues {
  public var bikesRepo: BikesRepo {
    get { self[BikesRepo.self] }
    set { self[BikesRepo.self] = newValue }
  }
}
