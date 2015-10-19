/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

enum FormattedComponentRequest {
  case Day
  case MonthYear
}

class LogDateFormatter {
  
  static let sharedFormatter = LogDateFormatter()
  
  /// Returns a string representation of a given date with details appropriate to display as a title.
  func detailFormattedDateFromDate(date: NSDate) -> String {
    return detailDateFormatter.stringFromDate(date)
  }
  
  /// Returns a string representation of a given date based on the specified component requeted.
  func formattedComponent(requestedComponent: FormattedComponentRequest, fromDate date: NSDate) -> String {
    let formatter: NSDateFormatter
    switch requestedComponent {
    case .Day:
      formatter = dayDateFormatter
    case .MonthYear:
      formatter = monthYearDateFormatter
    }
    return formatter.stringFromDate(date)
  }
  
  // MARK: Private
  
  /// A date formatter to use for converting NSDate to String for the purpose of displaying date as title.
  private let detailDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateStyle = .LongStyle
    formatter.timeStyle = .MediumStyle
    return formatter
    }()
  
  /// A date formatter to use for getting Day from a date.
  private let dayDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "dd"
    return formatter
    }()
  
  /// A date formatter to use for getting Month and Year only from a date.
  private let monthYearDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
    }()
  
}
