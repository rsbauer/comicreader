//
//  WindowService.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/10/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit
import PluggableAppDelegate

public protocol CoreDataServiceType {
}

public final class CoreDataService: NSObject, ApplicationService, CoreDataServiceType {
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // 2019-11-17 RSB: For next version, fetch CoreData objects which should be expired.  Then
        // delete them so they may be refreshed.
        
        return true
    }
}


