//
//  BikesDatabaseService.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import Foundation
import CoreData
import Models

extension NSSet {
  func toArray<T>() -> [T] {
    self.map { $0 as! T }
  }
}

extension Bike {
  public init?(entity: BikeEntity) {
    guard let id = entity.bikeId,
          let name = entity.name,
          let type = BikeType(rawValue: Int(entity.type)),
          let wheelSize = WheelSize(rawValue: Int(entity.wheelSize)),
          let color = entity.color else {
      return nil
    }
    
    let rides = entity.rides?.toArray().compactMap {
      Ride(entity: $0)
    } ?? []
    
    self.init(
      id: id,
      type: type,
      name: name,
      color: color,
      wheelSize: wheelSize,
      serviceDue: entity.serviceDue,
      isDefault: entity.isDefault,
      rides: rides
    )
  }
}

public class BikesDatabaseService {
  private let contextProvider: ContextProvider
  private var continuationsPool: [AsyncStream<[BikeEntity]>.Continuation] = []
  
  public init(contextProvider: ContextProvider = .sharedInstance) {
    self.contextProvider = contextProvider
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(managedObjectContextObjectsDidChange),
      name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
      object: contextProvider.viewContext
    )
  }
  
  public func addNewBike(bike: Bike) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        if bike.isDefault {
          let entities: [BikeEntity] = BikeEntity.fetchAll(context: context)
          entities.forEach {
            $0.isDefault = false
          }
        }
        
        let entity = BikeEntity(context: context)
        entity.bikeId = bike.id
        entity.name = bike.name
        entity.color = bike.color
        entity.isDefault = bike.isDefault
        entity.serviceDue = bike.serviceDue
        entity.type = Int32(bike.type.rawValue)
        entity.wheelSize = Int32(bike.wheelSize.rawValue)
        
        if context.saveIfNeeded() {
          continuation.resume()
        } else {
          continuation.resume(throwing: DBError.addEntityFailed)
        }
      }
    }
  }
  
  public func updateBike(bike: Bike) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let entities: [BikeEntity] = BikeEntity.fetchAll(context: context)
        entities.forEach { entity in
          if entity.bikeId == bike.id {
            entity.bikeId = bike.id
            entity.name = bike.name
            entity.color = bike.color
            entity.isDefault = bike.isDefault
            entity.serviceDue = bike.serviceDue
            entity.type = Int32(bike.type.rawValue)
            entity.wheelSize = Int32(bike.wheelSize.rawValue)
          } else {
            entity.isDefault = false
          }
        }
        
        if context.saveIfNeeded() {
          continuation.resume()
        } else {
          continuation.resume(throwing: DBError.updateEntityFailed)
        }
      }
    }
  }
  
  public func fetchBikes() -> AsyncStream<[BikeEntity]> {
    let stream = AsyncStream<[BikeEntity]> { [unowned self] continuation in
      let sortDescriptors = [NSSortDescriptor(keyPath: \BikeEntity.isDefault, ascending: false)]
      let entities: [BikeEntity] = BikeEntity.fetchAll(context: self.contextProvider.viewContext, sortDescriptors: sortDescriptors)
      continuation.yield(entities)
      
      continuation.onTermination = { [weak self] _ in
        self?.removeLastContinuation()
      }
      
      self.continuationsPool.append(continuation)
    }
    
    return stream
  }
  
  public func fetchBike(id: UUID) async throws -> BikeEntity {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(id)")
        guard let entity = BikeEntity.fetchFirst(context: context, predicate: predicate) as? BikeEntity else {
          continuation.resume(throwing: DBError.entityNotFound)
          return
        }
        
        continuation.resume(with: .success(entity))
      }
    }
  }
  
  public func deleteBike(id: UUID) async throws {
    try await withCheckedThrowingContinuation { continuation in
      let context = contextProvider.viewContext
      
      context.perform {
        let predicate = NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(id)")
        if let entity = BikeEntity.fetchFirst(context: context, predicate: predicate) {
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
      let sortDescriptors = [NSSortDescriptor(keyPath: \BikeEntity.isDefault, ascending: false)]
      let entities: [BikeEntity] = BikeEntity.fetchAll(context: context, sortDescriptors: sortDescriptors)
      
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
