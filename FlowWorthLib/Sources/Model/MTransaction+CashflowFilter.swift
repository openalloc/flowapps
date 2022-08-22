//
//  MTransaction+CashflowFilter.swift
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

extension MTransaction {
    
    /// Obtain unique (and not yet consumed) transactions that will be used to determine the cashflow
    /// filter transactions, starting with beginning of day of last snapshot
    public static func cashflowFilter(transactions: [MTransaction],
                                      userExcludedTxnKeys: [TransactionKey] = []) -> [MTransaction] {
        
        let userExcludedTxnKeySet = Set(userExcludedTxnKeys)

        var consumedKeySet = Set<TransactionKey>()
        
        return transactions.filter { txn in
            
            guard case let key = txn.primaryKey,
                  !consumedKeySet.contains(key), // if key is a duplicate, skip
                  !userExcludedTxnKeySet.contains(key) // if user excluded, skip
            else { return false }
            
            consumedKeySet.insert(key)
            return true
        }
    }
}
