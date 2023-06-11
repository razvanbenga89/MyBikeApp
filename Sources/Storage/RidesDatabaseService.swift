//
//  RidesDatabaseService.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import Foundation
import CoreData
import Models
import UserDefaultsConfig

extension Ride {
  public init?(entity: RideEntity) {
    guard let id = entity.rideId,
          let name = entity.name,
          let date = entity.date,
          let bikeId = entity.bike?.bikeId,
          let bikeName = entity.bike?.name,
          let bikeType = entity.bike?.type else {
      return nil
    }
    
    let savedRideDistance = Measurement(value: entity.distance, unit: UnitLength.kilometers)
    let convertedDistance = savedRideDistance.converted(to: UserDefaultsConfig.distanceUnit.unitLength)
    
    self.init(
      id: id,
      name: name,
      distance: convertedDistance.value,
      duration: Int(entity.duration),
      date: date,
      bikeId: bikeId,
      bikeName: bikeName,
      bikeType: BikeType(rawValue: Int(bikeType)) ?? .mtb
    )
  }
}

public actor RidesDatabaseService {
  private let contextProvider: ContextProvider
  private var continuationsPool: [AsyncStream<[RideEntity]>.Continuation] = []
  
  public init(contextProvider: ContextProvider = .sharedInstance) {
    self.contextProvider = contextProvider
  }
  
  public func setup() {
    Task { [weak self] in
      await self?.startListener()
    }
  }
  
  public nonisolated func addNewRide(ride: Ride) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let entity = RideEntity(context: context)
      entity.rideId = ride.id
      entity.name = ride.name
      entity.duration = Int32(ride.duration)
      entity.date = ride.date
      let bikeEntity = BikeEntity.fetchFirst(
        context: context,
        predicate: NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(ride.bikeId)")
      ) as? BikeEntity
      entity.bike = bikeEntity
      
      let rideDistance = Measurement(value: ride.distance, unit: UserDefaultsConfig.distanceUnit.unitLength)
      entity.distance = rideDistance.converted(to: UnitLength.kilometers).value
      
      guard context.saveIfNeeded() else {
        throw DBError.addEntityFailed
      }
    }
  }
  
  public nonisolated func updateRide(ride: Ride) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let predicate = NSPredicate(format: "%K = %@", #keyPath(RideEntity.rideId), "\(ride.id)")
      if let entity = RideEntity.fetchFirst(context: context, predicate: predicate) as? RideEntity {
        entity.name = ride.name
        entity.duration = Int32(ride.duration)
        entity.date = ride.date
        
        let rideDistance = Measurement(value: ride.distance, unit: UserDefaultsConfig.distanceUnit.unitLength)
        entity.distance = rideDistance.converted(to: UnitLength.kilometers).value
        
        let bikeEntity = BikeEntity.fetchFirst(
          context: context,
          predicate: NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(ride.bikeId)")
        ) as? BikeEntity
        entity.bike = bikeEntity
      }
      
      guard context.saveIfNeeded() else {
        throw DBError.updateEntityFailed
      }
    }
  }
  
  public func fetchRides() -> AsyncStream<[RideEntity]> {
    let stream = AsyncStream<[RideEntity]> { [unowned self] continuation in
      let sortDescriptors = [NSSortDescriptor(keyPath: \RideEntity.date, ascending: false)]
      let entities: [RideEntity] = RideEntity.fetchAll(context: self.contextProvider.viewContext, sortDescriptors: sortDescriptors)
      continuation.yield(entities)
      
      continuation.onTermination = { _ in
        Task { [weak self] in
          await self?.removeLastContinuation()
        }
      }
      
      self.continuationsPool.append(continuation)
    }
    
    return stream
  }
  
  public nonisolated func deleteRide(id: UUID) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let predicate = NSPredicate(format: "%K = %@", #keyPath(RideEntity.rideId), "\(id)")
      if let entity = RideEntity.fetchFirst(context: context, predicate: predicate) {
        context.delete(entity)
      }
      
      guard context.saveIfNeeded() else {
        throw DBError.deleteEntityFailed
      }
    }
  }
  
  private func startListener() async {
    for await notification in NotificationCenter.default.notifications(
      named: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
      object: contextProvider.viewContext
    ) {
      if let updatedContext = notification.object as? NSManagedObjectContext,
         updatedContext === contextProvider.viewContext {
        update(updatedContext)
      }
    }
  }
  
  private func update(_ context: NSManagedObjectContext) {
    context.perform { [unowned self, unowned context] in
      let sortDescriptors = [NSSortDescriptor(keyPath: \RideEntity.date, ascending: false)]
      let entities: [RideEntity] = RideEntity.fetchAll(context: context, sortDescriptors: sortDescriptors)
      
      self.continuationsPool.forEach {
        $0.yield(entities)
      }
    }
  }
  
  private func removeLastContinuation() {
    continuationsPool.removeLast()
  }
  
  deinit {
    continuationsPool.forEach {
      $0.finish()
    }
  }
}
