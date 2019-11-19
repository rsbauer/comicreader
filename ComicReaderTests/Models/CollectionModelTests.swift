//
//  CollectionModelTests.swift
//  ComicReaderTests
//
//  Created by Robert Bauer on 11/18/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import ComicReader
import XCTest

class CollectionModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test the model's ability to initialize and retain values
    func testCollectionModel_init_valuesStored() {
        let model = CollectionModel(cellName: "cellName", cellData: "someData" as AnyObject, isInSection: .media)
        
        XCTAssert(model.cellName == "cellName")
        guard let cellData = model.cellData as? String else {
            XCTAssertTrue(false)        // force fail the test
            return
        }
        
        XCTAssert(cellData == "someData")
        XCTAssert(model.isInSection == .media)
    }

}
