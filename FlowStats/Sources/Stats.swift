//
//  Stats.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Numerics
import Algorithms

public class Stats<T: BinaryFloatingPoint & Real>: Hashable {
   
    /// the input values upon which we'll build our estimates
    public let values: [T]
    
    public init(values: [T]) {
        self.values = values
    }
    
    public static func == (lhs: Stats<T>, rhs: Stats<T>) -> Bool {
        lhs.values == rhs.values
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(values)
    }
    
    public lazy var count: T = {
        T(values.count)
    }()
    
    public lazy var summed: T = {
        values.reduce(0, +)
    }()

    public lazy var mean: T? = {
        guard count > 0 else { return nil }
        return summed / count
    }()
    
    public lazy var min: T? = {
        minAndMax?.0
    }()
    
    public lazy var max: T? = {
        minAndMax?.1
    }()
    
    public lazy var range: ClosedRange<T>? = {
        guard let _min = min, let _max = max else { return nil }
        return _min ... _max
    }()
    
    // TODO optimize to scan through values only once
//    public lazy var extentRange: ClosedRange<T>? = {
//        let negSum = values.filter { $0 < 0 }.reduce(0, +)
//        let posSum = values.filter { $0 > 0 }.reduce(0, +)
//        return negSum...posSum
//    }()
    
    private lazy var minAndMax: (T, T)? = {
        values.minAndMax()
    }()
    
    public lazy var summedSquareError: T? = {
        guard let _mean = mean else { return nil }
        let ssq: T = values.reduce(0) {
            let ex = $1 - _mean
            return $0 + (ex * ex)
        }
        return ssq
    }()
    
    public lazy var variance: T? = {
        guard let _ssq = summedSquareError else { return nil }
        return _ssq / count
    }()
    
    public lazy var populationStandardDeviation: T? = {
        guard let _v = variance else { return nil }
        return sqrt(_v)
    }()
    
    // Dividing by n − 1 rather than by n gives an unbiased estimate of the variance of the larger parent population.
    public lazy var sampleStandardDeviation: T? = {
        guard let _ssq = summedSquareError, count > 1 else { return nil }
        return sqrt(_ssq / (count - 1))
    }()
    
    /// 68, 95, 99.7 rule
//    public lazy var empiricalRule: (ClosedRange<T>, ClosedRange<T>, ClosedRange<T>) = {
//       (
//        mean - populationStandardDeviation ... mean + populationStandardDeviation,
//        2 * mean - populationStandardDeviation ... 2 * mean + populationStandardDeviation,
//        3 * mean - populationStandardDeviation ... 3 * mean + populationStandardDeviation
//       )
//    }()
}
