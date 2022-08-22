//
//  BaseModel+Misc.swift
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

public extension BaseModel {
    
    var orderedSnapshots: [MValuationSnapshot] {
        valuationSnapshots
            .sorted(by: { $0.capturedAt < $1.capturedAt })
    }
   
    var orderedCashflowItems: [MValuationCashflow] {
        valuationCashflows
            .sorted()
    }

    var orderedTxns: [MTransaction] {
        transactions
            .sorted(by: { $0.transactedAt < $1.transactedAt })
    }
    
    var earliestHistory: MTransaction? {
        orderedTxns.first
    }
    
    var earliestHistoryTransactedAt: Date? {
        orderedTxns.first?.transactedAt
    }
    
    var latestSnapshot: MValuationSnapshot? {
        orderedSnapshots.last
    }
    
    var latestSnapshotCapturedAt: Date? {
        latestSnapshot?.capturedAt
    }
}
