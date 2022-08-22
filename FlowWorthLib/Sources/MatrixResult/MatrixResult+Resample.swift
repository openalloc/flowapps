//
//  MatrixResult+Resample.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase
import Accelerate
import SeriesResampler

extension MatrixResult {
    
    public static func resample<T: AllocKeyed>(_: T.Type,
                                               timeSeriesIndiceCount: Int,
                                               capturedAts: [Date],
                                               matrixValues: AllocKeyValuesMap<T>) -> AllocKeyValuesMap<T> {

        guard capturedAts.count > 0,
              capturedAts.count < timeSeriesIndiceCount
        else { return matrixValues }
        
        let timeIntervals = capturedAts.map { $0.timeIntervalSinceReferenceDate }
        guard let resampler = AccelLerpResamplerD(timeIntervals, targetCount: timeSeriesIndiceCount)
        else { return [:] }
        
        return matrixValues.reduce(into: [:]) { map, entry in
            let (key, market_values) = entry
            map[key] = resampler.resample(market_values)
        }
    }
}
