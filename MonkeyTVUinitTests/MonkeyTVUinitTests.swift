//
//  MonkeyTVUinitTests.swift
//  MonkeyTVUinitTests
//
//  Created by 王昱淇 on 2023/10/23.
//

import XCTest
@testable import MonkeyTV

final class MonkeyTVUinitTests: XCTestCase {
    
    var sut: LogInManager!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = LogInManager()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        try super.tearDownWithError()
    }
    
    func testLoginRequiredWhenLastLogin30DaysAgo() {
        let lastLoginDate = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        UserDefaults.standard.set(lastLoginDate, forKey: "lastLoginDate")
        XCTAssertTrue(LogInManager.checkIfLoginIsRequired())
    }
    
    func testLoginNotRequiredWhenLastLoginWithin30Days() {
        let lastLoginDate = Calendar.current.date(byAdding: .day, value: -29, to: Date())!
        UserDefaults.standard.set(lastLoginDate, forKey: "lastLoginDate")
        XCTAssertFalse(LogInManager.checkIfLoginIsRequired())
    }
    
    func testLoginRequiredWhenNoLastLoginDate() {
        UserDefaults.standard.removeObject(forKey: "lastLoginDate")
        XCTAssertFalse(LogInManager.checkIfLoginIsRequired())
    }
}
