//
//  PendingSnapshot+Model.swift
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
    
    /// NOTE reset context after committing
    mutating func commitPendingSnapshot(_ ps: PendingSnapshot) throws {
        //print("\(#function) ENTER"); defer { //print("\(#function) EXIT") }
        
        // store consumed history items, if any
        // store positions for snapshot to model.valuationPositions
        // store cashflow items to model.valuationCashflow
        // store new snapshot to model.valuationSnapshot
        
        // validate the holdings, snapshot, etc.
        try ps.validate()
        try self.validateSnapshot(snapshot: ps.snapshot)

        valuationPositions.append(contentsOf: ps.nuPositions)
        valuationCashflows.append(contentsOf: ps.nuCashflows)
        valuationSnapshots.append(ps.snapshot)
        
        clearBuilderDataFromModel()
    }
    
    mutating func clearBuilderDataFromModel() {
        // clear out workspace
        holdings.removeAll()
        transactions.removeAll()
    }
}
