//
//  FutureValueInfo.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import Regressor
import NiceScale

public struct FutureValueInfo: Hashable, Identifiable {
    public var id: Double
    public var futureValue: Double
    public var estimatedDate: Date
    
    internal init(futureValue: Double, estimatedDate: Date) {
        self.id = estimatedDate.timeIntervalSinceReferenceDate
        self.futureValue = futureValue
        self.estimatedDate = estimatedDate
    }

    public typealias LR = LinearRegressor<Double>
    typealias Point = LR.Point
}

extension FutureValueInfo: Comparable {
    public static func < (lhs: FutureValueInfo, rhs: FutureValueInfo) -> Bool {
        lhs.estimatedDate < rhs.estimatedDate
    }
}

extension FutureValueInfo {
    // generate a nice set of future values, whether positive or negative
    public static func getFutureValues(_ milestoneValues: [Double],
                                       begInterval: TimeInterval,
                                       lr: LR) -> [FutureValueInfo] {
        
        guard let lastPoint = lr.points.last else { return [] }
        
        let lastDate = Date(timeIntervalSinceReferenceDate: begInterval + lastPoint.x)
        
        return milestoneValues.reduce(into: []) { array, value in
            guard let date = getEstimatedDate(begInterval: begInterval, lr: lr, futureValue: value),
                  lastDate < date else { return }
            array.append(FutureValueInfo(futureValue: value, estimatedDate: date))
        }
    }
    
    public static func getNiceScale(lr: LR,
                                    multiplier: Double = 1.5,
                                    desiredTicks: Int = 10) -> NiceScale<Double>? {
        guard let firstPoint = lr.points.first,
              let lastPoint = lr.points.last,
              firstPoint.x < lastPoint.x
        else { return nil }
        
        let deltaInterval = lastPoint.x - firstPoint.x
        let futureInterval = firstPoint.x + (deltaInterval * multiplier)
        
        let lastMV = lastPoint.y
        let lastEstimate = lr.yRegression(x: lastPoint.x)
        let futureEstimate = lr.yRegression(x: futureInterval)
        let candidates = [lastMV, lastEstimate, futureEstimate]
        
        guard let minAndMax = candidates.minAndMax(),
              minAndMax.min < minAndMax.max
        else { return nil }
        
        let rawRange = minAndMax.min ... minAndMax.max
        return NiceScale(rawRange, desiredTicks: desiredTicks)
    }
    
    internal static func getEstimatedDate(begInterval: TimeInterval,
                                          lr: LR,
                                          futureValue: Double) -> Date? {
        let relativeDistance = lr.xEstimate(y: futureValue)
        return Date(timeIntervalSinceReferenceDate: begInterval + relativeDistance)
    }
}

