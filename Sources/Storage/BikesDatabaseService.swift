//
//  BikesDatabaseService.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import Foundation
import CoreData
import Models
import UserDefaultsConfig

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
    
    let savedServiceDue = Measurement(value: entity.serviceDue, unit: UnitLength.kilometers)
    let convertedServiceDue = savedServiceDue.converted(to: UserDefaultsConfig.distanceUnit.unitLength)
    
    self.init(
      id: id,
      type: type,
      name: name,
      color: color,
      wheelSize: wheelSize,
      serviceDue: convertedServiceDue.value,
      isDefault: entity.isDefault,
      latestService: entity.lastestService,
      rides: rides
    )
  }
}

public actor BikesDatabaseService {
  private let contextProvider: ContextProvider
  private var continuationsPool: [AsyncStream<[BikeEntity]>.Continuation] = []
  
  public init(contextProvider: ContextProvider = .sharedInstance) {
    self.contextProvider = contextProvider
  }
  
  public func setup() {
    Task { [weak self] in
      await self?.startListener()
    }
  }
  
  public nonisolated func addNewBike(bike: Bike) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
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
      entity.type = Int32(bike.type.rawValue)
      entity.wheelSize = Int32(bike.wheelSize.rawValue)
      
      let bikeServiceDue = Measurement(value: bike.serviceDue, unit: UserDefaultsConfig.distanceUnit.unitLength)
      entity.serviceDue = bikeServiceDue.converted(to: .kilometers).value
      
      guard context.saveIfNeeded() else {
        throw DBError.addEntityFailed
      }
    }
  }
  
  public func fetchBikes() -> AsyncStream<[BikeEntity]> {
    let stream = AsyncStream<[BikeEntity]> { [unowned self] continuation in
      let sortDescriptors = [NSSortDescriptor(keyPath: \BikeEntity.isDefault, ascending: false)]
      let entities: [BikeEntity] = BikeEntity.fetchAll(context: self.contextProvider.viewContext, sortDescriptors: sortDescriptors)
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
  
  public nonisolated func updateBike(bike: Bike) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let entities: [BikeEntity] = BikeEntity.fetchAll(context: context)
      entities.forEach { entity in
        if entity.bikeId == bike.id {
          entity.bikeId = bike.id
          entity.name = bike.name
          entity.color = bike.color
          entity.isDefault = bike.isDefault
          entity.type = Int32(bike.type.rawValue)
          entity.wheelSize = Int32(bike.wheelSize.rawValue)
          
          let bikeServiceDue = Measurement(value: bike.serviceDue, unit: UserDefaultsConfig.distanceUnit.unitLength)
          entity.serviceDue = bikeServiceDue.converted(to: .kilometers).value
        } else {
          entity.isDefault = false
        }
      }
      
      guard context.saveIfNeeded() else {
        throw DBError.updateEntityFailed
      }
    }
  }
  
  public nonisolated func updateBikeToDefault(id: UUID) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let entities: [BikeEntity] = BikeEntity.fetchAll(context: context)
      entities.forEach { entity in
        entity.isDefault = entity.bikeId == id
      }
      
      guard context.saveIfNeeded() else {
        throw DBError.updateEntityFailed
      }
    }
  }
  
  public nonisolated func updateLatestService(id: UUID, date: Date) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let predicate = NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(id)")
      guard let entity = BikeEntity.fetchFirst(context: context, predicate: predicate) as? BikeEntity else {
        throw DBError.entityNotFound
      }
      
      entity.lastestService = date
      
      guard context.saveIfNeeded() else {
        throw DBError.updateEntityFailed
      }
    }
  }
  
  public nonisolated func fetchBike(id: UUID) async throws -> BikeEntity {
    let context = contextProvider.viewContext
    
    let entity = try await context.perform {
      let predicate = NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(id)")
      guard let entity = BikeEntity.fetchFirst(context: context, predicate: predicate) as? BikeEntity else {
        throw DBError.entityNotFound
      }
      
      return entity
    }
    
    return entity
  }
  
  public nonisolated func deleteBike(id: UUID) async throws {
    let context = contextProvider.viewContext
    
    try await context.perform {
      let predicate = NSPredicate(format: "%K = %@", #keyPath(BikeEntity.bikeId), "\(id)")
      guard let entity = BikeEntity.fetchFirst(context: context, predicate: predicate) else {
        throw DBError.entityNotFound
      }
      
      context.delete(entity)
      
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
