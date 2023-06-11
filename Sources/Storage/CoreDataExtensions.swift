//
//  CoreDataExtensions.swift
//  
//
//  Created by Razvan Benga on 31.05.2023.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
  @discardableResult
  func saveIfNeeded() -> Bool {
    guard hasChanges else {
      return true
    }
    
    do {
      try self.save()
      return true
    } catch {
      return false
    }
  }
}

extension NSManagedObject {
  static func count(context: NSManagedObjectContext) -> Int {
    (try? context.count(for: Self.fetchRequest())) ?? 0
  }
  
  static func fetchFirst<T: NSManagedObject>(context: NSManagedObjectContext, predicate: NSPredicate? = nil) -> T? {
    fetchAll(context: context, predicate: predicate).first
  }
  
  static func fetchAll<T: NSManagedObject>(context: NSManagedObjectContext, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> [T] {
    let fetchRequest = Self.fetchRequest()
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    return (try? context.fetch(fetchRequest)) as? [T] ?? []
  }
  
  static func deleteAll(context: NSManagedObjectContext, completionHandler: ((Bool) -> Void)? = nil) {
    context.perform { [unowned context] in
      let entities = Self.fetchAll(context: context)
      entities.forEach {
        context.delete($0)
      }
      
      let savedSuccessfully = context.saveIfNeeded()
      completionHandler?(savedSuccessfully)
    }
  }
}
