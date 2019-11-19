//
//  AppDelegate.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/13/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit
import CoreData
import PluggableAppDelegate
import Swinject

protocol AppDelegateType {
    var window: UIWindow? { get set }
    var container: Container { get set }
    var persistentContainer: NSPersistentContainer { get }
    
    func saveContext()
}

@UIApplicationMain
class AppDelegate: PluggableApplicationDelegate, AppDelegateType {
    
    lazy var container = Container { inboundContainer in
        weak var weakContainer = inboundContainer
        inboundContainer.register(CoreDataServiceType.self) { _ in CoreDataService() }
        inboundContainer.register(NetworkProviderType.self) { _ in NetworkProvider() }
        inboundContainer.register(DataStoreProviderType.self) { [weak self] _ in
            DataStoreProvider(context: self?.persistentContainer.viewContext)
        }
    }

    override var services: [ApplicationService] {
        return [
            (container.resolve(CoreDataServiceType.self) as! ApplicationService)
        ]
    }
    
    override init() {
        super.init()
    }


    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        // 2019-11-17 RSB: For now, letting persistent container be stored in the default location.  One option
        // might be to use the cache directory so iOS can perform cleanup.
        
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ComicReader")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // leaving fatalError here so the app will crash.  For production, remove and replace with a nice
                // alert UI.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    public func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                
                // POC app, leaving fatalError(...) here as is
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

