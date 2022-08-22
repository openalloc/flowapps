//
//  PendingSnapshot+Validate.swift
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

extension PendingSnapshot {
    
    // earliest allowable date for new snapshot (24 hrs after last snapshot, if any)
    // limit to after last snapshot, if any
    public var minimumDate: Date? {
        if let previousCapturedAt = previousSnapshot?.capturedAt {
            return previousCapturedAt.addingTimeInterval(86400) // so it shows up 24 hours after in Date Picker
        }
        return nil
    }
}

extension PendingSnapshot {
    
    /// return nil if ready to commit; otherwise a message with an isWarning bool
    public func canCommit(ax: BaseContext,
                          nuCapturedAt: Date,
                          //remainingReconciledCashflowCount: Int,
                          now: Date = Date()) -> (String, Bool)? {
        
        guard nuPositions.count > 0 else {
            return ("Ready for import!", false)
        }
        
        if let _minimumDate = minimumDate {
            guard _minimumDate <= nuCapturedAt,
                  _minimumDate <= now
            else {
                return ("Less than 24 hours since last Snapshot.", true)
            }
        }
        
        guard nuCapturedAt < now else {
            return ("Must be in the past.", true)
        }
        
        do {
            try MSecurity.validateDeep(against: ax)
        } catch let error as FlowBaseError {
            return (error.description, true)
        } catch {
            return (error.localizedDescription, true)
        }
        
        for txn in netTransactions {
            // SharePrice not required on import, but needed for snapshot creation
            if txn.sharePrice == nil {
                return ("Share price required on all selected transactions. Complete transactions in data model.", true)
            }
        }

        return nil
    }
}

extension PendingSnapshot {
    
    public func validate() throws {
        try netHoldings.forEach {
            try MValuationPosition.validate(holding: $0, securityMap: securityMap) }
        
        try MValuationSnapshot.validateSnapshot(previousSnapshotCapturedAt: previousSnapshot?.capturedAt,
                                                timestamp: timestamp)
        
        try nuPositions.forEach { try $0.validate() }
        
        try transactions.forEach {
            
            // NOTE it's okay for sharePrice to be nil, as in the case of a security transfer where price at transfer isn't specified
            try $0.validate()
        }
    }
}
