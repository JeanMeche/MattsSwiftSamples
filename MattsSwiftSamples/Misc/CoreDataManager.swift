//
//  CoreDataManager.swift
//  MattsSwiftSamples
//
//  Created by Matthieu Riegler on 25/07/16.
//  Copyright © 2016 Matthieu Riegler. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class CoreDataManager {
    
    /**
     Performs a save on the context if it has changes
     */
    static func save(context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch let exception {
                print("CoreData save error : \(exception)")
            }
        }
    }
    
    /**
     - returns: The main context provided by the AppDelegate
     */
    static func mainContext() -> NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    /**
     - Returns: A new context of PrivateQueueConcurrencyType
     */
    static func backgroundContext() -> NSManagedObjectContext {
        let backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.persistentStoreCoordinator = (UIApplication.sharedApplication().delegate as! AppDelegate).persistentStoreCoordinator
        backgroundContext.mergePolicy = NSMergePolicy(mergeType: NSMergePolicyType.MergeByPropertyStoreTrumpMergePolicyType)
        
        return backgroundContext
    }
    
    class func fetch<T:NSManagedObject>(t:T.Type, inContext context:NSManagedObjectContext=CoreDataManager.mainContext(), withPredicate predicate:NSPredicate?=nil, andSortDescriptors sortDescriptors:[NSSortDescriptor]?=nil, fetchLimit:Int?=nil) -> [T] {
        
        let entities:[T]
        
        let request = NSFetchRequest(entityName:(t.description().componentsSeparatedByString(".").last!))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        do {
            entities = try context.executeFetchRequest(request) as! [T]
        } catch let exception as NSError  {
            print(exception.localizedDescription)
            entities = [T]()
        }
        
        return entities
    }
}