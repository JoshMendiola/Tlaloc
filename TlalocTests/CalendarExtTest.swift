//
//  TlalocTests.swift
//  TlalocTests
//
//  Created by Joshua Mendiola on 4/19/22.
//
import XCTest
@testable import Tlaloc

class CalendarExtTest: XCTestCase
{
    override func setUpWithError() throws
    {
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
    
    
    func testCalendarExtMinusMonth() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        dateComponents.year = 2002
        dateComponents.month = 10
        dateComponents.day = 21
        let outputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(outputDate, calendarExt().minusMonth(date: inputDate!))
    }
    
    func testCalendarExtDayString() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual("21", calendarExt().dayString(date: inputDate!))
    }
    
    func testCalendarExtMonthString() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual("November", calendarExt().monthString(date: inputDate!))
    }
    
    func testCalendarExtYearString() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual("2002", calendarExt().yearString(date: inputDate!))
    }
    
    func testCalendarExtDaysInMonth() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(30, calendarExt().daysInMonth(date: inputDate!))
    }
    
    func testCalendarExtDaysOfMonth() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(21, calendarExt().dayOfMonth(date: inputDate!))
    }
    
    func testCalendarExtFirstOfMonth() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 01
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        var outputDateComponents = dateComponents
        outputDateComponents.year = 2002
        outputDateComponents.month = 12
        let outputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(outputDate, calendarExt().firstOfMonth(date: inputDate!))
    }
    
    func testCalendarExtWeekDay() throws
    {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 11
        dateComponents.day = 21
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let inputDate = Calendar.current.date(from: dateComponents)
        
        XCTAssertEqual(4, calendarExt().weekDay(date: inputDate!))
    }
}
