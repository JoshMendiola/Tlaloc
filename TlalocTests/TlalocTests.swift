//
//  TlalocTests.swift
//  TlalocTests
//
//  Created by Joshua Mendiola on 4/19/22.
//

import XCTest
@testable import Tlaloc

class TlalocTests: XCTestCase
{
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCalendarExtPlusMonth() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        let inputDate = Calendar.current.date(from: dateComponents)
        
        dateComponents.year = 2002
        dateComponents.month = 12
        dateComponents.day = 21
        let outputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(outputDate, calendarExt().plusMonth(date: inputDate!))
    }

}
