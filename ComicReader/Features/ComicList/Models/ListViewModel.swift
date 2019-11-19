//
//  File.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import ReactiveKit
import Bond

public class ListViewModel {
    // // //
    // MARK: - Observables
    // // //
    
    public private(set) var title = Observable("")
    public private(set) var items = MutableObservableArray<CollectionModel>([])
    public private(set) var repository: MarvelRepositoryType?
    public private(set) var error: Observable<Error?> = Observable(nil)

    private var disposeBag: DisposeBag = DisposeBag()
    private var listCollectionViewData: [AnyObject] = []
    private let loadingCellData: AnyObject = ListCollectionViewData(title: "Loading...") as AnyObject
    private var copyrightData: AnyObject = ListCollectionViewData(title: "Attribution not available") as AnyObject

    private enum Constants {
        static let listCellName = "ListCollectionViewCell"
        static let bookCellName = "BookCollectionViewCell"
    }
    
    init() {
        let model = CollectionModel(cellName: Constants.listCellName,
                                    cellData: loadingCellData as AnyObject,
                                    isInSection: .loading)
        items.append(model)
    }
    
    public func shutdown() {
        disposeBag.dispose()
        disposeBag = DisposeBag()
        
        items.removeAll()
        items = MutableObservableArray<CollectionModel>([])
    }
    
    public func registerCollectionViewCells(collectionView: UICollectionView) {
        let cellsToRegister = [
            Constants.listCellName,
            Constants.bookCellName
        ]
        
        for cell in cellsToRegister {
            let nib = UINib(nibName: cell, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: cell)
        }
    }
    
    public func setItems(mediaCollection: [Media]) {
        items.removeAll()
        for media in mediaCollection {
            let model = CollectionModel(cellName: Constants.bookCellName,
                                        cellData: media as AnyObject,
                                        isInSection: .media)
            items.append(model)
        }
    }
    
    public func setRepository(repository: MarvelRepositoryType) {
        self.repository = repository
        repository.getMedia { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                strongSelf.error.value = error
            case .success(let media):
                strongSelf.processMedia(media)
            }
        }
    }
    
    func processMedia(_ mediaItems: [Media]) {
        listCollectionViewData.removeAll()
        items.removeAll()
        
        for media in mediaItems {
            let cellData = media as AnyObject
            listCollectionViewData.append(cellData)
            items.append(CollectionModel(cellName: Constants.bookCellName,
                                         cellData: cellData,
                                         isInSection: .media))
        }

        if let attribution = UserDefaults.standard.value(forKey: MediaData.Constants.attributionKey) as? String {
            copyrightData = ListCollectionViewData(title: attribution) as AnyObject
            items.append(CollectionModel(cellName: Constants.listCellName, cellData: copyrightData, isInSection: .copyright))
        }
    }
}
