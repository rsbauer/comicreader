//
//  DataProvider.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreData

public typealias DataStoreProviderCompletionHandler = (Result<[Media], Error>) -> Void
public typealias DataStoreProviderSaveHandler = (Result<Bool, Error>) -> Void

public protocol DataStoreProviderType {
    func getMedia(completionHandler: DataStoreProviderCompletionHandler?)
    func saveMedia(_ media: [Media], saveHandler: DataStoreProviderSaveHandler?)
}

public class DataStoreProvider: DataStoreProviderType {
    private let context: NSManagedObjectContext?
    
    private enum Constants {
        static let mediaEntityName = "MediaObj"
    }
    
    init(context: NSManagedObjectContext?) {
        self.context = context
    }
    
    public func getMedia(completionHandler: DataStoreProviderCompletionHandler?) {
        var media: [Media] = []
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MediaObj")
        request.returnsObjectsAsFaults = false
        
        do {
            if let result = try context?.fetch(request) as? [NSManagedObject] {
                for data in result {
                    if let mediaObject = Media(entity: data) {
                        media.append(mediaObject)
                    }
                }
                completionHandler?(.success(media))
            }
        } catch {
            completionHandler?(.failure(error))
        }
    }
    
    public func saveMedia(_ media: [Media], saveHandler: DataStoreProviderSaveHandler?) {
        guard let context = context else {
            saveHandler?(.failure(NSError(domain: "Failed to save media.", code: 100, userInfo: nil)))
            return
        }
        
        deleteAllMedia()
        
        guard let entity = NSEntityDescription.entity(forEntityName: Constants.mediaEntityName, in: context) else {
            saveHandler?(.failure(NSError(domain: "Failed to get entity.", code: 100, userInfo: nil)))
            return
        }
        
        for item in media {
            let mediaEntity = NSManagedObject(entity: entity, insertInto: context)
            item.populateEntity(entity: mediaEntity)
        }
        
        do {
            try context.save()
            saveHandler?(.success(true))
        } catch {
            saveHandler?(.failure(NSError(domain: "Failed to save media", code: 101, userInfo: nil)))
        }
    }
    
    public  func deleteAllMedia() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.mediaEntityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context?.execute(deleteRequest)
        } catch {
            print("Failed to delete all media: \(error.localizedDescription)")
        }
    }
}
