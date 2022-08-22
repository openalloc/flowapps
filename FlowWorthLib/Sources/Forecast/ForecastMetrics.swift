//
//  ForecastMetrics.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public final class ForecastMetrics {
    public let mainTimestamps: [Date]
    public let extendedSnapshotCount : Int

    public init(mainTimestamps: [Date],
                extendedSnapshotCount: Int = 0) {
        self.mainTimestamps = mainTimestamps
        self.extendedSnapshotCount = extendedSnapshotCount
    }
    
    // MARK: - Durations
    
    public lazy var mainDuration: TimeInterval? = {
        mainRange?.duration
    }()
    
    public lazy var mainAverageDuration: TimeInterval? = {
        guard let _mainRange = mainRange,
              mainTimestamps.count > 0
        else { return nil }
        return _mainRange.duration / Double(mainTimestamps.count)
    }()
    
    public lazy var extendedDuration: TimeInterval? = {
        guard let _mainAverageDuration = mainAverageDuration else { return nil }
        return Double(extendedSnapshotCount - 1) * _mainAverageDuration
    }()
    
    public lazy var combinedDuration: TimeInterval? = {
        guard let _mainDuration = mainDuration,
              let _extendedDuration = extendedDuration
        else { return nil }
        return _mainDuration + _extendedDuration
    }()
    
    // MARK: - Fractions (combined is 1)
    
    public lazy var mainFraction: Double? = {
        guard let _mainDuration = mainDuration,
              let _combinedDuration = combinedDuration
        else { return nil }
        return _mainDuration / _combinedDuration
    }()
    
    public lazy var extendedFraction: Double? = {
        guard let _mainFraction = mainFraction
        else { return nil }
        return 1 - _mainFraction
    }()
    
    // MARK: - Ranges
    
    public lazy var mainRange: DateInterval? = {
        guard let first = mainTimestamps.first,
              let last = mainTimestamps.last
        else { return nil }
        return DateInterval(start: first, end: last)
    }()
    
    public lazy var begInterval: TimeInterval? = {
        mainTimestamps.first?.timeIntervalSinceReferenceDate
    }()
    
    public lazy var extendedRange: DateInterval? = {
        guard let _mainRange = mainRange,
              let _extendedDuration = extendedDuration
        else { return nil }
        return DateInterval(start: _mainRange.end, duration: _extendedDuration)
    }()
    
    public lazy var combinedRange: DateInterval? = {
        guard let _mainRange = mainRange,
              let _combinedDuration = combinedDuration
        else { return nil }
        return DateInterval(start: _mainRange.start, duration: _combinedDuration)
    }()
    
    // MARK: - distances (all relative to first timestamp)
    
    public lazy var mainDistances: [TimeInterval] = {
        guard let _begInterval = begInterval else { return [] }
        return mainTimestamps.map { $0.timeIntervalSinceReferenceDate - _begInterval }
    }()
    
    public lazy var begMainDistance: TimeInterval? = {
        mainDistances.first   // should be zero
    }()
    
    public lazy var endMainDistance: TimeInterval? = {
        mainDistances.last
    }()
    
    public lazy var extendedDistances: [TimeInterval] = {
        guard let _endMainDistance = endMainDistance,
              let _mainAverageDuration = mainAverageDuration
        else { return [] }
        return (0..<extendedSnapshotCount).map {
            _endMainDistance + (Double($0) * _mainAverageDuration)
        }
    }()

    public lazy var combinedDistances: [TimeInterval] = {
        mainDistances + extendedDistances.dropFirst()
    }()
    
    // MARK: - Timestamps
    
    public lazy var extendedTimestamps: [Date] = {
        guard let _begInterval = begInterval else { return [] }
        return extendedDistances.map { Date(timeIntervalSinceReferenceDate: _begInterval + $0) }
    }()
    
    public lazy var combinedTimestamps: [Date] = {
        mainTimestamps + extendedTimestamps.dropFirst()
    }()
}
