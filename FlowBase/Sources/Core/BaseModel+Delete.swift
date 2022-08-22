//
//  BaseModel+Delete.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public extension BaseModel {
    
    mutating func delete(_ account: MAccount) {
        let pk = account.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MAccount.ID) {
        caps.removeAll(where: { $0.accountKey == pk })
        holdings.removeAll(where: { $0.accountKey == pk })
        accounts.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ allocation: MAllocation) {
        let pk = allocation.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MAllocation.ID) {
        allocations.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ asset: MAsset) {
        let pk = asset.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MAsset.ID) {
        for n in 0..<assets.count {
            guard assets[n].parentAssetKey == pk else { continue }
            assets[n].parentAssetID = ""
        }
        for n in 0..<securities.count {
            guard securities[n].assetKey == pk else { continue }
            securities[n].assetID = ""
        }
        allocations.removeAll(where: { $0.assetKey == pk })
        caps.removeAll(where: { $0.assetKey == pk })
        assets.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ holding: MHolding) {
        let pk = holding.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MHolding.ID) {
        holdings.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ security: MSecurity) {
        let pk = security.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MSecurity.ID) {
        holdings.removeAll(where: { $0.securityKey == pk })
        securities.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ strategy: MStrategy) {
        let pk = strategy.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MStrategy.ID) {
        for n in 0..<accounts.count {
            guard accounts[n].strategyKey == pk else { continue }
            accounts[n].strategyID = ""
        }
        allocations.removeAll(where: { $0.strategyKey == pk })
        strategies.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ index: MTracker) {
        let pk = index.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MTracker.ID) {
        for n in 0..<securities.count {
            guard securities[n].trackerKey == pk else { continue }
            securities[n].trackerID = ""
        }
        trackers.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ cap: MCap) {
        let pk = cap.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MCap.ID) {
        caps.removeAll(where: { $0.primaryKey == pk })
    }

    mutating func delete(_ transaction: MTransaction) {
        let pk = transaction.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MTransaction.ID) {
        transactions.removeAll(where: { $0.primaryKey == pk })
    }
    
    mutating func delete(_ item: MValuationSnapshot) {
        let pk = item.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MValuationSnapshot.ID) {
        valuationPositions.removeAll(where: { $0.snapshotKey == pk })
        valuationSnapshots.removeAll(where: { $0.primaryKey == pk })
        
        // NOTE explicitly not deleting cashflow in range of snapshot
    }
    
    mutating func delete(_ item: MValuationPosition) {
        let pk = item.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MValuationPosition.ID) {
        valuationPositions.removeAll(where: { $0.primaryKey == pk })
    }
    
    mutating func delete(_ item: MValuationCashflow) {
        let pk = item.primaryKey
        delete(pk)
    }
        
    mutating func delete(_ pk: MValuationCashflow.ID) {
        valuationCashflows.removeAll(where: { $0.primaryKey == pk })
    }
}
