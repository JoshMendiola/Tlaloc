//
//  calenderExt.swift
//  Tlaloc
//
//  Created by Joshua Mendiola on 4/3/22.
//

import Foundation
import UIKit

//NOTE:: This class has 100% test coverage

//these extensions exist to further serve and simplify the code requried for the calendar in plantListViewController, each handling specific calculations that make writing calendar code easier
class calendarExt
{
    let calendar = Calendar.current
    
    //these calculalte the given month either one month in the future or one month in the past, returning a new date
    func plusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: 1, to: date)!
    }
    
    func minusMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month, value: -1, to: date)!
    }
    
    
    //these format dates into strings by their specific parts, each acting as one part of a calendar date
    func dayString(date: Date) -> String
    {
        
        let dateFormatter = DateFormatter()
        //returns the day of a date, by its actual day of the month, so "March 14th 2022" would return '14'
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date)
    }
    
    func monthString(date: Date) -> String
    {
        //returns the month of a date, by the name of the month itself, so "March 14th, 2022" would return 'March'
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date: Date) -> String
    {
        //returns the year of a date, by the number of the year itself, so "March 14th, 2022" would return '2022'
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    
    //returns the amount of days in  a given month, needed to set the amount of cells that should be in the calendar
    func daysInMonth(date: Date) -> Int
    {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    //returns the day of month that a day is, depending on the specific date passed into it, needed to assign cells their specific placements in the month
    func dayOfMonth(date: Date) -> Int
    {
        let components = calendar.dateComponents([.day], from: date)
        return components.day!
    }
    
    //returns the first day of every month, so the calendar knows where to place the first cell
    func firstOfMonth(date: Date) -> Date
    {
        let components = calendar.dateComponents([.year,.month], from: date)
        return calendar.date(from: components)!
    }
    
    //returns the actual day in terms of the week day, so April 19, 2022 would return "Tuesday"
    func weekDay(date: Date) -> Int
    {
        let components = calendar.dateComponents([.weekday], from: date)
        return components.weekday! - 1
    }
}
