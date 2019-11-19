//
//  CollectionModel.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Foundation

/// A model to define a cell to be used in a collection.
public class CollectionModel: NSObject {

    /// String cell class name
    public private(set) var cellName: String
    
    /// AnyObject meta data to go with the cell
    public private(set) weak var cellData: AnyObject?
    
    /// Section the cell belongs to
    public private(set) var isInSection: Section

    /// Section name
    public private(set) var sectionName: String = ""

    /// Possible sections found in a collection view
    public enum Section {
        case media
        case loading
        case copyright
        case unknown
    }
    
    /// Initialize the model
    ///
    /// - Parameters:
    ///   - cellName: String class name of cell to be used
    ///   - cellData: AnyObject meta data to go with the cell
    ///   - isInSection: Section enum which attempts to work in the concept of sections in a collectionview
    public init(cellName: String, cellData: AnyObject?, isInSection: Section) {
        self.cellName = cellName
        self.cellData = cellData
        self.isInSection = isInSection
        super.init()
    }
    
    public init(cellName: String, cellData: AnyObject?, isInSectionNamed: String) {
        self.cellName = cellName
        self.cellData = cellData
        self.isInSection = .unknown
        
        super.init()
        self.sectionName = isInSectionNamed
    }
}
