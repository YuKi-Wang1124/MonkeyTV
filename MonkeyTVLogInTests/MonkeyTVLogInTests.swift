//
//  MonkeyTVLogInTests.swift
//  MonkeyTVLogInTests
//
//  Created by 王昱淇 on 2023/10/23.
//

import XCTest
@testable import MonkeyTV
import AuthenticationServices

final class MonkeyTVLogInTests: XCTestCase {
    
    var sut: ProfileViewController!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = ProfileViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }

    func testLogOut() {
        sut.logOut()
        XCTAssertTrue(KeychainItem.currentEmail.isEmpty, "KeychainItem.currentEmail should be empty")
        XCTAssertNil(sut.myUserInfo, "myUserInfo should be nil")
    }
    
    func testUserBlock() {
        let userId = "user123"
        let blockUserId = "blockedUser456"
        
        let expectation = XCTestExpectation(description: "UserBlock operation completed")
        
        FirestoreManager.userBlock(userId: userId, blockUserId: blockUserId)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)

    }
}
