//
//  NetworkProviderTests.swift
//  ComicReaderTests
//
//  Created by Robert Bauer on 11/13/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import ComicReader
import OHHTTPStubs
import XCTest

class NetworkProviderTests: XCTestCase {
    
    private var provider = NetworkProvider()

    private enum Constants {
        static let expectationTimeOutInSeconds: TimeInterval = 10.0
    }

    override func setUp() {
        provider = NetworkProvider()
    }

    override func tearDown() {
    }
    
    /// A bit of a silly test - just validating regardless of the url used, the call back does get called
    func testGet_anyUrl_callbackCalled() {
        let expectation = self.expectation(description: "\(#function)")
        var callBackWasCalled = false
        
        provider.get(url: "http://www.rsb0.com") { (response) in
            callBackWasCalled = true
            expectation.fulfill()
        }
                
        waitForExpectations(timeout: Constants.expectationTimeOutInSeconds) { (error) in
            if let errorMsg = error?.localizedDescription {
                XCTFail(errorMsg)
                return
            }
        }
        
        XCTAssertTrue(callBackWasCalled)
    }
    
    func testSaveMedia_call_shouldFail() {
        let expectation = self.expectation(description: "\(#function)")
        var hadError = false

        provider.saveMedia([]) { (result) in
            if case .failure(_) = result {
                hadError = true
            }
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeOutInSeconds) { (error) in
            if let errorMsg = error?.localizedDescription {
                XCTFail(errorMsg)
                return
            }
        }

        XCTAssertTrue(hadError)
    }

    func testGetMedia_invalidKeys_failWithError() {
        keyTest(privateKey: nil, publicKey: nil)
        keyTest(privateKey: "", publicKey: "")
        keyTest(privateKey: nil, publicKey: "")
        keyTest(privateKey: "", publicKey: nil)
        keyTest(privateKey: "key", publicKey: "")
        keyTest(privateKey: "", publicKey: "key")
    }
    
    private func keyTest(privateKey: String?, publicKey: String?) {
        let expectation = self.expectation(description: "\(#function)")
        var hadError = false

        provider.getMedia(publicKey: publicKey, privateKey: privateKey) { (result) in
            if case .failure(_) = result  {
                hadError = true
            }
            
            expectation.fulfill()
        }

        waitForExpectations(timeout: Constants.expectationTimeOutInSeconds) { (error) in
            if let errorMsg = error?.localizedDescription {
                XCTFail(errorMsg)
                return
            }
        }
        
        XCTAssertTrue(hadError)
    }
    
    func testGetMedia_validUrl_success() {
        stub(condition: isHost("gateway.marvel.com")) { request in
          return OHHTTPStubsResponse(
            fileAtPath: OHPathForFile("developer.marvel.com.json", type(of: self))!,
            statusCode: 200,
            headers: ["Content-Type":"application/json"]
          )
        }
        
        let expectation = self.expectation(description: "\(#function)")
        var hadError = false
        
        provider.getMedia { (response) in
            switch response {
            case .failure(_):
                // If needed, it might be nice to capture the error and report it - for now, just flag if there was an
                // error
                hadError = true
            case .success(let media):
                XCTAssertEqual(media.count, 3)
                if let first = media.first {
                    // Santity check to make sure the test is using the mock json
                    XCTAssertEqual(first.title, "First Title")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: Constants.expectationTimeOutInSeconds) { (error) in
            if let errorMsg = error?.localizedDescription {
                XCTFail(errorMsg)
                return
            }
        }

        XCTAssertFalse(hadError)
    }

    func testGetMedia_validUrlInvalidJson_generatesError() {
        stub(condition: isHost("gateway.marvel.com")) { request in
          return OHHTTPStubsResponse(
            fileAtPath: OHPathForFile("nonmedia.json", type(of: self))!,
            statusCode: 200,
            headers: ["Content-Type":"application/json"]
          )
        }
        
        let expectation = self.expectation(description: "\(#function)")
        var hadError = false
        
        provider.getMedia { (response) in
            switch response {
            case .failure(let error):
                hadError = true
                XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it isn’t in the correct format.")
            case .success(_):
                break
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: Constants.expectationTimeOutInSeconds) { (error) in
            if let errorMsg = error?.localizedDescription {
                XCTFail(errorMsg)
                return
            }
        }

        XCTAssertTrue(hadError)
    }
    
    func testProcessResult_validJson_success() {
        guard let pathString = Bundle(for: type(of: self)).path(forResource: "developer.marvel.com", ofType: "json") else {
            XCTAssertEqual("Unable to locate json", "JSON found")  // silly test designed to fail
            return
        }
        
        guard let jsonString = try? String(contentsOfFile: pathString, encoding: .utf8) else {
            XCTAssertEqual("Unable to read json file", "\(#function)")  // silly test designed to fail
            return
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            XCTAssertEqual("Unable to convert string to Data", "\(#function)")  // silly test designed to fail
            return
        }
        
        let result = provider.processResult(jsonData as AnyObject)
        switch result {
        case .failure(let error):
            XCTAssertNotNil(error)  // error will not be nil so fail the test
        case .success(let media):
            mediaModelsTest(media: media)
        }
    }
    
    /// Test the array and individual model items
    ///
    /// - Parameter media: Media array
    private func mediaModelsTest(media: [Media]) {
        XCTAssertEqual(media.count, 3)
        guard let first = media.first else {
            XCTAssertEqual("Found First", "Did not find first")  // silly fail test to fail the overall test
            return
        }
        
        XCTAssertEqual(first.title, "First Title")
        XCTAssertEqual(first.id, 12345)
        XCTAssertEqual(first.pageCount, 160)
        XCTAssertEqual(first.thumbnail, "http://i.annihil.us/u/prod/marvel/i/mg/9/a0/5db85ca74e760.jpg")
    }

}

