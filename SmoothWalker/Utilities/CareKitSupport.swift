/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A collection of utility functions used for charting and visualizations.
*/

import Foundation
import CareKitUI

// MARK: - Chart Date UI

/// Return a label describing the date range of the chart for the last week. Example: "Jun 3 - Jun 10, 2020"
func createChartWeeklyDateRangeLabel(lastDate: Date = Date()) -> String {
    let calendar: Calendar = .current
    
    let endOfWeekDate = lastDate
    let startOfWeekDate = getLastWeekStartDate(from: endOfWeekDate)
    
    let monthDayDateFormatter = DateFormatter()
    monthDayDateFormatter.dateFormat = "MMM d"
    let monthDayYearDateFormatter = DateFormatter()
    monthDayYearDateFormatter.dateFormat = "MMM d, yyyy"
    
    var startDateString = monthDayDateFormatter.string(from: startOfWeekDate)
    var endDateString = monthDayYearDateFormatter.string(from: endOfWeekDate)
    
    // If the start and end dates are in the same month.
    if calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .month) {
        let dayYearDateFormatter = DateFormatter()
        
        dayYearDateFormatter.dateFormat = "d, yyyy"
        endDateString = dayYearDateFormatter.string(from: endOfWeekDate)
    }
    
    // If the start and end dates are in different years.
    if !calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .year) {
        startDateString = monthDayYearDateFormatter.string(from: startOfWeekDate)
    }
    
    return String(format: "%@–%@", startDateString, endDateString)
}

func createChartMonthlyDateRangeLabel(lastDate: Date = Date()) -> String {
    let calendar: Calendar = .current
    
    let endOfMonthDate = lastDate
    let startOfMonthDate = getLastMonthStartDate(from: endOfMonthDate)
    
    let monthDayDateFormatter = DateFormatter()
    monthDayDateFormatter.dateFormat = "MMM d"
    let monthDayYearDateFormatter = DateFormatter()
    monthDayYearDateFormatter.dateFormat = "MMM d, yyyy"
    
    var startDateString = monthDayDateFormatter.string(from: startOfMonthDate)
    var endDateString = monthDayYearDateFormatter.string(from: endOfMonthDate)
    
    // If the start and end dates are in the same month.
    if calendar.isDate(startOfMonthDate, equalTo: endOfMonthDate, toGranularity: .month) {
        let dayYearDateFormatter = DateFormatter()
        
        dayYearDateFormatter.dateFormat = "d, yyyy"
        endDateString = dayYearDateFormatter.string(from: endOfMonthDate)
    }
    
    // If the start and end dates are in different years.
    if !calendar.isDate(startOfMonthDate, equalTo: endOfMonthDate, toGranularity: .year) {
        startDateString = monthDayYearDateFormatter.string(from: startOfMonthDate)
    }
    
    return String(format: "%@–%@", startDateString, endDateString)
}

func createChartTodayLabel(today: Date = Date()) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy"
    return dateFormatter.string(from: today)
}

private func createMonthDayDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "MMM-d"
    
    return dateFormatter
}

private func createHoursDateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "H"
    
    return dateFormatter
}

func createChartDateLastUpdatedLabel(_ dateLastUpdated: Date) -> String {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateStyle = .medium
    
    return "last updated on \(dateFormatter.string(from: dateLastUpdated))"
}

/// Returns an array of horizontal axis markers based on the desired time frame, where the last axis marker corresponds to `lastDate`
/// `useWeekdays` will use short day abbreviations (e.g. "Sun, "Mon", "Tue") instead.
/// Defaults to showing the current day as the last axis label of the chart and going back one week.
func createHorizontalAxisMarkers(lastDate: Date = Date(), useWeekdays: Bool = true) -> [String] {
    let calendar: Calendar = .current
    let weekdayTitles = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var titles: [String] = []
    
    if useWeekdays {
        titles = weekdayTitles
        
        let weekday = calendar.component(.weekday, from: lastDate)
        
        return Array(titles[weekday..<titles.count]) + Array(titles[0..<weekday])
    } else {
        let numberOfTitles = weekdayTitles.count
        let endDate = lastDate
        let startDate = calendar.date(byAdding: DateComponents(day: -(numberOfTitles - 1)), to: endDate)!
        
        let dateFormatter = createMonthDayDateFormatter()

        var date = startDate
        
        while date <= endDate {
            titles.append(dateFormatter.string(from: date))
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return titles
    }
}

func createHorizontalAxisMarkers(for dates: [Date]) -> [String] {
    let dateFormatter = createMonthDayDateFormatter()
    let items = itemsAtIndicesMultiple(of: 7, dates: dates)
    return items.map { dateFormatter.string(from: $0) }
}

func createDayHorizontalAxisMarkers(for dates: [Date]) -> [String] {
    let dateFormatter = createHoursDateFormatter()
    let items = itemsAtIndicesMultiple(of: 3, dates: dates)
    return items.map { dateFormatter.string(from: $0) }
}

func getDatesRange(from: Date, to: Date) -> [Date] {
    // in case of the "from" date is more than "to" date,
    // it should returns an empty array:
    if from > to { return [Date]() }

    var tempDate = from
    var array = [tempDate]

    while tempDate < to {
        tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
        array.append(tempDate)
    }

    return array
}

func getHoursRange(from: Date, to: Date) -> [Date] {
    // in case of the "from" date is more than "to" date,
    // it should returns an empty array:
    if from > to { return [Date]() }

    var tempDate = from
    var array = [tempDate]

    while tempDate < to {
        tempDate = Calendar.current.date(byAdding: .hour, value: 1, to: tempDate)!
        array.append(tempDate)
    }
    
    return array
}

func itemsAtIndicesMultiple(of number: Int, dates: [Date]) -> [Date] {
    return dates.enumerated().compactMap { tuple in
        tuple.offset.isMultiple(of: number) ? tuple.element : nil }
}

func getStartDate(from timeRange: TimeRange) -> Date {
    switch timeRange {
    case .Day:
        return getBeginningOfDate()
    case .Week:
        return getLastWeekStartDate()
    case .Month:
        return getLastMonthStartDate()
    }
}

func createPredicate(from timeRange: TimeRange) -> NSPredicate{
    switch timeRange {
    case .Day:
        return createTodayPredicate()
    case .Week:
        return createLastWeekPredicate()
    case .Month:
        return createLastMonthPredicate()
    }
}

func getInterval(from timeRange: TimeRange) -> DateComponents{
    switch timeRange {
    case .Day:
        return DateComponents(hour: 1)
    case .Week:
        return DateComponents(day: 1)
    case .Month:
        return DateComponents(day: 1)
    }
}

func getHorizontalAxisMarkers(from timeRange: TimeRange) -> [String] {
    let now = Date()
    switch timeRange {
    case .Day:
        let beginningOfDay:Date = getBeginningOfDate()
        let todayHours:[Date] = getHoursRange(from: beginningOfDay, to: now)
        return createDayHorizontalAxisMarkers(for: todayHours)
    case .Week:
        return createHorizontalAxisMarkers()
    case .Month:
        let lastMonthStartDate: Date = getLastMonthStartDate()
        let lastMonthDates:[Date] = getDatesRange(from: lastMonthStartDate, to: now)
        return createHorizontalAxisMarkers(for: lastMonthDates)
    }
}

func getChartDateRangeLabel(from timeRange: TimeRange) -> String {
    switch timeRange {
    case .Day:
        return createChartTodayLabel()
    case .Week:
        return createChartWeeklyDateRangeLabel()
    case .Month:
        return createChartMonthlyDateRangeLabel()
    }
}
