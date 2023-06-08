//
//  RidesDatabaseService.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import Foundation
import CoreData
import Models

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
    
    self.init(
      id: id,
      name: name,
      distance: entity.distance,
      duration: Int(entity.duration),
      date: date,
      bikeId: bikeId,
      bikeName: bikeName,
      bikeType: BikeType(rawValue: Int(bikeType)) ?? .mtb
    )
  }
}

public class RidesDatabaseService {
  private let contextProvider: ContextProvider
  private var continuationsPool: [AsyncStream<[RideEntity]>.Continuation] = []
  
  public init(contextProvider: ContextProvider = .sharedInstance) {
    self.contextProvider = contextProvider
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(managedObjectContextObjectsDidChange),
      name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
      object: contextProvider.viewContext
    )
  }
  
  public func addNewRide(ride: Ride) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let entity = RideEntity(context: context)
        entity.rideId = ride.id
        entity.name = ride.name
        entity.distance = ride.distance
        entity.duration = Int32(ride.duration)
        entity.date = ride.date
        let bikeEntity = BikeEntity.fetchFirst(
          context: context,
          predicate: NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(ride.bikeId)")
        ) as? BikeEntity
        entity.bike = bikeEntity
        
        if context.saveIfNeeded() {
          continuation.resume()
        } else {
          continuation.resume(throwing: DBError.addEntityFailed)
        }
      }
    }
  }
  
  public func updateRide(ride: Ride) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(RideEntity.rideId), "\(ride.id)")
        if let entity = RideEntity.fetchFirst(context: context, predicate: predicate) as? RideEntity {
          entity.name = ride.name
          entity.distance = ride.distance
          entity.duration = Int32(ride.duration)
          entity.date = ride.date
          let bikeEntity = BikeEntity.fetchFirst(
            context: context,
            predicate: NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(ride.bikeId)")
          ) as? BikeEntity
          entity.bike = bikeEntity
        }
        
        if context.saveIfNeeded() {
          continuation.resume()
        } else {
          continuation.resume(throwing: DBError.updateEntityFailed)
        }
      }
    }
  }
  
  public func fetchRides() -> AsyncStream<[RideEntity]> {
    let stream = AsyncStream<[RideEntity]> { [unowned self] continuation in
      let sortDescriptors = [NSSortDescriptor(keyPath: \RideEntity.date, ascending: false)]
      let entities: [RideEntity] = RideEntity.fetchAll(context: self.contextProvider.viewContext, sortDescriptors: sortDescriptors)
      continuation.yield(entities)
      
      continuation.onTermination = { [weak self] _ in
        self?.removeLastContinuation()
      }
      
      self.continuationsPool.append(continuation)
    }
    
    return stream
  }
  
  public func deleteRide(id: UUID) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(RideEntity.rideId), "\(id)")
        if let entity = RideEntity.fetchFirst(context: context, predicate: predicate) {
          context.delete(entity)
        }
        
        if context.saveIfNeeded() {
          continuation.resume()
        } else {
          continuation.resume(throwing: DBError.deleteEntityFailed)
        }
      }
    }
  }
  
  @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
    guard let updatedContext = notification.object as? NSManagedObjectContext else {
      return
    }
    
    if updatedContext === contextProvider.viewContext {
      update(updatedContext)
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
