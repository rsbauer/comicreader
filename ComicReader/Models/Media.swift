//
//  Media.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreData

public struct MediaData: Codable {
    public enum Constants {
        static let attributionKey = "attributionText"
    }
    
    let data: MediaResults
    let attributionText: String
    
    public func saveAttributionText() {
        UserDefaults.standard.set(attributionText, forKey: Constants.attributionKey)
    }
}

public struct MediaResults: Codable {
    let results: [Media]
}

public struct Media: Codable {
    public let id: Int
    public let title: String
    public let pageCount: Int
    public let thumbnail: String
    
    enum CodingKeys: String, CodingKey, Decodable {
        case id
        case title
        case pageCount
        case thumbnail
    }

    public init() {
        id = 0
        title = "Empty media"
        pageCount = 0
        thumbnail = ""
    }

    public init(id: Int, title: String, thumbnail: String, pageCount: Int) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.pageCount = pageCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        pageCount = try container.decode(Int.self, forKey: .pageCount)
        
        let thumb = try container.nestedContainer(keyedBy: MediaThumbnail.CodingKeys.self, forKey: .thumbnail)
        let path = try thumb.decode(String.self, forKey: .path)
        let extensionName = try thumb.decode(String.self, forKey: .extensionName)
        thumbnail = "\(path).\(extensionName)"
    }
        
    public init?(entity: NSManagedObject) {
        guard let id = entity.value(forKey: "id") as? Int,
            let title = entity.value(forKey: "title") as? String,
            let pageCount = entity.value(forKey: "pageCount") as? Int,
            let thumbnail = entity.value(forKey: "thumbnail") as? String
            else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.pageCount = pageCount
        self.thumbnail = thumbnail
    }
    
    public func populateEntity(entity: NSManagedObject) {
        entity.setValue(title, forKey: "title")
        entity.setValue(id, forKey: "id")
        entity.setValue(pageCount, forKey: "pageCount")
        entity.setValue(thumbnail, forKey: "thumbnail")
    }
}

public struct MediaThumbnail: Codable {
    public let path: String
    public let extensionName: String
    
    enum CodingKeys: String, CodingKey {
        case path
        case extensionName = "extension"
    }
}
