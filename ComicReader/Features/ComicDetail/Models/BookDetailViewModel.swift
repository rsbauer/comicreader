//
//  BookDetailViewModel.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/18/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit

public class BookDetailViewModel {
    
    public private(set) var id = Observable(0)
    public private(set) var title = Observable("")
    public private(set) var thumbnail = Observable("")
    public private(set) var pageCount = Observable(0)
    
    private var media: Media {
        willSet(newValue) {
            title.value = newValue.title
            thumbnail.value = newValue.thumbnail
            id.value = newValue.id
            pageCount.value = newValue.pageCount
        }
    }
    
    public init() {
        media = Media()
    }
        
    public func shutdown() {
    }
    
    public func setMedia(media: Media) {
        self.media = media
    }
}
