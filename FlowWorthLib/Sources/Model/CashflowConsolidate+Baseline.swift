//
//  CashflowConsolidate+Baseline.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import ModifiedDietz
import AllocData

import FlowBase

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

private let df = ISO8601DateFormatter()

public typealias AccountAssetBaselineMap = [AccountAssetKey: MyBaseline]

public class MyBaseline {
    let period: DateInterval
    let performance: Double // R (if 0, then W will be inf/nan)
    let startValue: Double // A
    let endValue: Double // B
    let netCashflow: Double // F (if 0, then W will be inf/nan)
    let epsilon: Double
    
    public init(period: DateInterval,
                performance: Double,
                startValue: Double,
                endValue: Double,
                netCashflow: Double,
                epsilon: Double = 0.0001) {
        self.period = period
        self.performance = performance
        self.startValue = startValue
        self.endValue = endValue
        self.netCashflow = netCashflow
        self.epsilon = epsilon
    }
    
    // The proportion of the time period between the START of the period and when the flow occurs.
    // beginning of period: w == 0
    // end of period: w == 1
    // This weight assumes a single (consolidated) cash flow record for the account/asset.
    lazy var rawWeight: Double = {
        let num = endValue - netCashflow - (startValue * (performance + 1))
        
        // if no change in value, place CF at end of period
        guard num.isNotEqualToZero(accuracy: epsilon) else {
            return 1
        }
                    
        let den = performance * netCashflow
        
        // if no netCashflow, place at end of period
        guard den.isNotEqualToZero(accuracy: epsilon) else {
            return 1
        }
        
        return 1 - (num / den)
    }()
    
    lazy var weight: Double = {
        rawWeight.clamped(to: 0...1)
    }()
    
    lazy var netDate: Date = {
        var d = period.at(weight)
        
        // exclude the exact start of the period, as it belongs to previous period
        // jump one second into the period
        if d == period.start {
            d += 1
            print("JUMPED")
        }
        print("weight=\(weight.percent4()) d=\(df.string(from: d)) p=\(performance.percent4()) s=\(startValue.currency0()) e=\(endValue.currency0()), ncf=\(netCashflow.currency2())")
        return d
    }()
}

extension MyBaseline: Equatable {
    public static func == (lhs: MyBaseline, rhs: MyBaseline) -> Bool {
        lhs.period == rhs.period &&
        lhs.performance.isEqual(to: rhs.performance, accuracy: lhs.epsilon) &&
        lhs.startValue.isEqual(to: rhs.startValue, accuracy: lhs.epsilon) &&
        lhs.endValue.isEqual(to: rhs.endValue, accuracy: lhs.epsilon) &&
        lhs.netCashflow == rhs.netCashflow
    }
}
