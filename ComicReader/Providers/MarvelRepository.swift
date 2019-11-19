//
//  StorageProvider.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Swinject

public protocol MarvelRepositoryType {
    func getMedia(completionHandler: DataStoreProviderCompletionHandler?)
}

public class MarvelRepository: MarvelRepositoryType {
    
    private let dataProvider: DataStoreProviderType
    private let networkProvider: NetworkProvider
    
    init(container: Container) {
        // would prefer not using as! here but DataProvider will always be available
        dataProvider = container.resolve(DataStoreProviderType.self) as! DataStoreProvider
        networkProvider = container.resolve(NetworkProviderType.self) as! NetworkProvider
    }
    
    public func getMedia(completionHandler: DataStoreProviderCompletionHandler?) {
        dataProvider.getMedia { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                completionHandler?(.failure(error))
            case .success(let media):
                strongSelf.processMedia(media, completionHandler: completionHandler)
            }
        }
    }
    
    private func processMedia(_ media: [Media], completionHandler: DataStoreProviderCompletionHandler?) {
        guard media.isEmpty else {
            completionHandler?(.success(media))
            return
        }
        
        // no items from dataProvider (disk) means this might be the first time the app has run or the data
        // was deleeted.  Make a network call to get/refresh
        networkProvider.getMedia { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(_):
                completionHandler?(result)
                return
            case .success(let media):
                strongSelf.dataProvider.saveMedia(media) { (saveResult) in
                    if case .failure(_) = saveResult {
                        completionHandler?(result)
                        return
                    }
                }
            }

            completionHandler?(result)
        }
    }
}
