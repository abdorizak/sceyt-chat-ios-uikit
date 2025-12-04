//
//  TimeIntervalFormatter.swift
//  SceytChatUIKit
//
//  Created by Sceyt LLC. All rights reserved.
//

import Foundation

/// A formatter for displaying time intervals in human-readable format.
/// Supports multiple time units (years, months, weeks, days, hours, minutes, seconds)
/// and locale-aware list formatting.
open class TimeIntervalFormatter: TimeIntervalFormatting {

    public init() {}

    /// Formats a time interval into a human-readable string.
    ///
    /// - Parameter timeInterval: The time interval in seconds to format.
    /// - Returns: A formatted string representing the time interval.
    ///
    /// Examples:
    /// - `0` → "Off"
    /// - `45` → "45 seconds"
    /// - `3600` → "1 hour"
    /// - `90000` → "1 day and 1 hour"
    /// - `2678400` → "1 month and 1 week"
    open func format(_ timeInterval: TimeInterval) -> String {
        // Handle negative or invalid values
        if timeInterval < 0 {
            return "Unknown duration"
        }

        // Handle off state
        if timeInterval == 0 {
            return L10n.Time.Interval.off
        }

        // Handle seconds only (less than a minute)
        if timeInterval < 60 {
            let seconds = Int(timeInterval)
            if seconds == 1 {
                return L10n.Time.Interval.Second.one
            } else {
                return L10n.Time.Interval.Second.multiple(seconds)
            }
        }

        var remainingSeconds = Int(timeInterval)
        var parts: [String] = []

        // Years (365 days = 31,536,000 seconds)
        let years = remainingSeconds / 31_536_000
        if years > 0 {
            if years == 1 {
                parts.append(L10n.Time.Interval.Year.one)
            } else {
                parts.append(L10n.Time.Interval.Year.multiple(years))
            }
            remainingSeconds %= 31_536_000
        }

        // Months (30 days = 2,592,000 seconds)
        let months = remainingSeconds / 2_592_000
        if months > 0 {
            if months == 1 {
                parts.append(L10n.Time.Interval.Month.one)
            } else {
                parts.append(L10n.Time.Interval.Month.multiple(months))
            }
            remainingSeconds %= 2_592_000
        }

        // Weeks (7 days = 604,800 seconds)
        let weeks = remainingSeconds / 604_800
        if weeks > 0 {
            if weeks == 1 {
                parts.append(L10n.Time.Interval.Week.one)
            } else {
                parts.append(L10n.Time.Interval.Week.multiple(weeks))
            }
            remainingSeconds %= 604_800
        }

        // Days (86,400 seconds)
        let days = remainingSeconds / 86_400
        if days > 0 {
            if days == 1 {
                parts.append(L10n.Time.Interval.Day.one)
            } else {
                parts.append(L10n.Time.Interval.Day.multiple(days))
            }
            remainingSeconds %= 86_400
        }

        // Hours (3,600 seconds)
        let hours = remainingSeconds / 3_600
        if hours > 0 {
            if hours == 1 {
                parts.append(L10n.Time.Interval.Hour.one)
            } else {
                parts.append(L10n.Time.Interval.Hour.multiple(hours))
            }
            remainingSeconds %= 3_600
        }

        // Minutes (60 seconds)
        let minutes = remainingSeconds / 60
        if minutes > 0 {
            if minutes == 1 {
                parts.append(L10n.Time.Interval.Minute.one)
            } else {
                parts.append(L10n.Time.Interval.Minute.multiple(minutes))
            }
        }

        // Format the result based on number of parts
        if parts.isEmpty {
            return L10n.Time.Interval.Minute.multiple(0)
        }

        // Use ListFormatter for locale-aware list formatting
        return formatList(parts)
    }

    /// Formats a list of time unit strings into a single string with proper conjunctions.
    ///
    /// Uses iOS 13+ ListFormatter when available for locale-aware formatting,
    /// otherwise falls back to manual formatting with localized strings.
    ///
    /// - Parameter parts: Array of time unit strings (e.g., ["1 day", "2 hours"])
    /// - Returns: A formatted string with proper conjunctions
    private func formatList(_ parts: [String]) -> String {
        switch parts.count {
        case 1:
            return parts[0]
        case 2:
            // Use .end format for 2 items: "1 day and 2 hours"
            return L10n.Time.Interval.Format.end(parts[0], parts[1])
        default:
            // Build string progressively for 3+ items
            var result = ""
            for (index, part) in parts.enumerated() {
                if index == 0 {
                    result = part
                } else if index == parts.count - 1 {
                    result = L10n.Time.Interval.Format.end(result, part)
                } else {
                    result = L10n.Time.Interval.Format.middle(result, part)
                }
            }
            return result
        }
    }
}
