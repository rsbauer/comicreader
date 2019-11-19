//
//  BookDetailViewModel.swift
//  ComicReaderTests
//
//  Created by Robert Bauer on 11/18/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ComicReader
import ReactiveKit
import XCTest


class BookDetailViewModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit_noMedia_observeNextIsCalled() {
        let viewModel = BookDetailViewModel()
        let disposeBag = DisposeBag()
        let expect = self.expectation(description: "\(#function)")
        expect.expectedFulfillmentCount = 4

        
        viewModel.title.observeNext { (value) in
            XCTAssertEqual(value, "")
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.thumbnail.observeNext { (value) in
            XCTAssertEqual(value, "")
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.id.observeNext { (value) in
            XCTAssertEqual(value, 0)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.pageCount.observeNext { (value) in
            XCTAssertEqual(value, 0)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        waitForExpectations(timeout: 2, handler: nil)
        disposeBag.dispose()
    }
    
    
    func testInit_setMedia_observeNextIsCalled() {
        let viewModel = BookDetailViewModel()
        let disposeBag = DisposeBag()
        let expect = self.expectation(description: "\(#function)")
        expect.expectedFulfillmentCount = 4

        let media = Media(id: 1, title: "title", thumbnail: "thumbnail", pageCount: 2)
        viewModel.setMedia(media: media)
        
        viewModel.title.observeNext { (value) in
            XCTAssertEqual(value, media.title)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.thumbnail.observeNext { (value) in
            XCTAssertEqual(value, media.thumbnail)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.id.observeNext { (value) in
            XCTAssertEqual(value, media.id)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        viewModel.pageCount.observeNext { (value) in
            XCTAssertEqual(value, media.pageCount)
            expect.fulfill()
        }.dispose(in: disposeBag)
        
        waitForExpectations(timeout: 2, handler: nil)
        disposeBag.dispose()
    }
}
