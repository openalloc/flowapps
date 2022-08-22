//
//  BaseModel+ImportHordes.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter

extension BaseModel {
    public typealias AllocBaseKeyPath<T: AllocBase> = WritableKeyPath<BaseModel, [T]>
    
    /// NOTE used BOTH in import and unpack (file load)
    mutating public func importHordes(_ data: Data,
                                      finPorter: FINporter,
                                      schema: AllocSchema,
                                      rejectedRows: inout [AllocRowed.RawRow],
                                      finFormat: AllocFormat? = nil,
                                      url: URL? = nil,
                                      timestamp: Date? = nil,
                                      timeZone: TimeZone,
                                      defTimeOfDay: String?) throws
    {
        switch schema {
        case .allocAccount:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MAccount.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.accounts)
            }
        case .allocAllocation:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MAllocation.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.allocations)
            }
        case .allocAsset:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MAsset.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.assets)
            }
        case .allocHolding:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MHolding.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.holdings)
            }
        case .allocSecurity:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MSecurity.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                var item = $0
                item["updatedAt"] = timestamp
                _ = try importRow(item, into: \.securities)
            }
        case .allocStrategy:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MStrategy.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.strategies)
            }
        case .allocTracker:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MTracker.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.trackers)
            }
        case .allocCap:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MCap.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.caps)
            }
        case .allocTransaction:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MTransaction.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.transactions)
            }
        case .allocValuationSnapshot:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MValuationSnapshot.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.valuationSnapshots)
            }
        case .allocValuationPosition:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MValuationPosition.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.valuationPositions)
            }
        case .allocValuationCashflow:
            let items: [AllocRowed.DecodedRow] = try finPorter.decode(MValuationCashflow.self, data, rejectedRows: &rejectedRows, inputFormat: finFormat, outputSchema: schema, url: url, defTimeOfDay: defTimeOfDay, timeZone: timeZone)
            try items.forEach {
                _ = try importRow($0, into: \.valuationCashflows)
            }
        default:
            _ = 0
        }
    }
}
