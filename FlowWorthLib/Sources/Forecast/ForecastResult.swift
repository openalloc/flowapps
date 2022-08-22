//
//  ForecastResult.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SeriesResampler

import AllocData
import Regressor
import FlowBase

// NOTE this should NOT have scaled (0..1) marketvalues (y-axis), OR
// resampled time series (x-axis).
//
// That can be done in the view using the static helper functions.

public final class ForecastResult {
    
    public typealias LR = LinearRegressor<Double>
    public typealias Point = LR.Point

    public let timeSeriesIndiceCount = 160 // includes both main and extended
    public let extendedSnapshotCount = 5
    public let epsilon = 0.01
    
    public let snapshots: ArraySlice<MValuationSnapshot>
    public let marketValueMap: SnapshotValueMap
    
    public init(snapshots: ArraySlice<MValuationSnapshot>,
                marketvalueMap: SnapshotValueMap) {
        self.snapshots = snapshots
        self.marketValueMap = marketvalueMap
    }
    
    public lazy var mainDuration: TimeInterval = {
        guard let first = snapshots.first,
              let last = snapshots.last
        else { return 0 }
        return first.capturedAt.distance(to: last.capturedAt)
    }()

    public lazy var daysInMainPeriod: Double = {
        mainDuration / 24 / 60 / 60
    }()

    public lazy var yearsInMainPeriod: Double = {
        daysInMainPeriod / 365.25
    }()

    // the NET market values for all the snapshots
    public lazy var mainMarketValues: [Double] = {
        snapshots.map { marketValueMap[$0.primaryKey] ?? 0 }
    }()
    
    /// the NET market values of all snapshots will fall within this range, inclusive (on y-axis)
    public lazy var marketValueRange: ClosedRange<Double>? = {
        guard let minMax = mainMarketValues.minAndMax(),
              minMax.min.isNotEqual(to: minMax.max, accuracy: epsilon)
        else { return nil }
        return (minMax.min) ... (minMax.max)
    }()
    
    public lazy var mainCapturedAts: [Date] = {
        snapshots.map(\.capturedAt)
    }()
    
    public lazy var maxMV: Double = {
        mainMarketValues.max() ?? 0
    }()
    
    public lazy var mainRelativePoints: [Point] = {
        guard let firstCapturedAt = snapshots.first?.capturedAt else { return [] }
        return snapshots.reduce(into: []) { array, snapshot in
            let relativeDistance = firstCapturedAt.distance(to: snapshot.capturedAt)
            let marketValue = marketValueMap[snapshot.primaryKey] ?? 0
            array.append(Point(x: relativeDistance, y: marketValue))
        }
    }()

    // MARK: - Regression Line (built from main data)
    
    public lazy var lr: LR? = {
        LinearRegressor(points: mainRelativePoints)
    }()
    
    // MARK: - Projected data
    
    // formerly horizontalMetrics
    public lazy var hm: ForecastMetrics = {
        ForecastMetrics(mainTimestamps: mainCapturedAts,
                        extendedSnapshotCount: extendedSnapshotCount)
    }()
        
    // MARK: - Resampled MAIN data
    
    public lazy var mainTimeSeriesIndiceCount: Int = {
        guard let _mainFraction = hm.mainFraction else { return 0 }
        let rawValue = Double(timeSeriesIndiceCount) * _mainFraction
        return Int(rawValue.rounded())
    }()
    
    /// resample over main distances
    public lazy var mainResampler: BaseResampler? = {
        AccelLerpResamplerD(hm.mainDistances, targetCount: mainTimeSeriesIndiceCount)
    }()
    
    /// marketvalues from [4, 1, 8] to [4, 3, 2, 1, 1, 3, 5, 6, 8] for snapshots=3 and timeSeriesIndiceCount=9
    public lazy var mainResampled: [Double] = {
        guard let rs = mainResampler else { return [] }
        return rs.resample(mainMarketValues)
    }()

    // MARK: - Resampled COMBINED data
    
    public lazy var combinedResampler: BaseResampler? = {
        AccelLerpResamplerD(hm.combinedDistances, targetCount: timeSeriesIndiceCount)
    }()
    
    public lazy var combinedResampled: [Double] = {
        guard let rs = combinedResampler,
              let _lr = lr
        else { return [] }
        let distances = hm.combinedDistances
        let rawVals = distances.map { _lr.yRegression(x: $0) }
        return rs.resample(rawVals)
    }()
}
