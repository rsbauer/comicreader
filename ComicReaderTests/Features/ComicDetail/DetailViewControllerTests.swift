//
//  DetailViewControllerTests.swift
//  ComicReaderTests
//
//  Created by Robert Bauer on 11/13/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import ComicReader
import Swinject
import XCTest

class DetailViewControllerTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }
    
    public func testViewController_getsReleased_noLeaks() {
        weak var weakViewController: UIViewController?
        let container = Container()

        // concept from
        //  https://stackoverflow.com/questions/42490856/how-to-test-for-uiviewcontroller-retain-cycles-in-a-unit-test
        autoreleasepool { () -> Void in
            var viewController: UIViewController? = DetailViewController(container: container, media: Media())
            _ = viewController?.view        // needed to exercise the view and get it wired up so the views are not nil
                                            // and do not crash the tests
            viewController?.viewDidLoad()
            weakViewController = viewController
            viewController = nil
        }
        
        XCTAssertNil(weakViewController)
    }
}
