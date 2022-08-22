//
//  PendingSnapshot+Cashflow.swift
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

extension MValuationCashflow {
    
    static private let ONE_MINUTE = 60.0 // seconds
    
    /// The cashflow period starts one second after the start of the snapshot period, if there's any previous snapshot. It ends at the same time as the snapshot period.
    static func getCashflowPeriod(begCapturedAt: Date?, endCapturedAt: Date) -> DateInterval? {
        guard let netStart = begCapturedAt?.addingTimeInterval(ONE_MINUTE),
              netStart < endCapturedAt
        else { return nil }
        return DateInterval(start: netStart, end: endCapturedAt)
    }
    
    /// NOTE does NOT consolidate on CashflowKey
    static func generateCashflow(from txns: [MTransaction],
                                 period: DateInterval,
                                 securityMap: SecurityMap) -> [MValuationCashflow] {
        txns.reduce(into: []) { cashflows, txn in
            let security = securityMap[txn.securityKey]
            
            func generate(_ assetID: AssetID,
                          _ amount: Double,
                          transactedAt: Date? = nil) {
                
                let netTransactedAt = period.clamp(transactedAt ?? txn.transactedAt)
                
                cashflows.append(.init(transactedAt: netTransactedAt,
                                       accountID: txn.accountID,
                                       assetID: assetID,
                                       amount: amount))
            }
            
            let cashAssetID = MAsset.cashAssetID // "Cash"
            
            guard let mv = txn.marketValue else {
                print("generateCashflow: missing marketvalue")
                return
            }
            
            switch txn.action {
            case .buysell:
                guard let _security = security,
                      !_security.isCashAsset
                else { return }
                // NEUTRAL: No external flows involved in this exchange within the portfolio.
                // if purchase (+MV), we exchange cash for the asset
                // if sale (-MV), we exchange the asset for cash
                generate(_security.assetID, mv)
                generate(cashAssetID, -mv)
                
            case .income:
                // If dividend, we 'sell' the income from asset for cash.
                // If interest, just generate a cash exchange (TODO can we do better?)
                let _assetID = security?.assetID ?? cashAssetID
                generate(_assetID, -mv)
                generate(cashAssetID, mv)
                
            case .transfer:
                // if transferring out securities (where MV<0), treat it as a sale to cash (to record profit), and then transfer cash out
                if let _security = security,
                   !_security.isCashAsset,
                   mv < 0
                {
                    generate(_security.assetID, mv) // sale of security...
                    generate(cashAssetID, -mv) // ...to cash
                    generate(cashAssetID, mv, transactedAt: period.end) // flow cash out ----- TODO is this third param still needed?
                } else {
                    let _assetID = security?.assetID ?? cashAssetID
                    generate(_assetID, mv) // flow (asset or cash)
                }
                
            case .miscflow:
                generate(cashAssetID, mv)
            }
        }
    }
}

// MARK: - Reconcile

extension MValuationCashflow {
    
    /// make reconcile cashflow records, except for cash (which can reflect income)
    static func makeCashflow(from map: AccountAssetValueMap,
                             timestamp: Date,
                             accountMap: AccountMap,
                             assetMap: AssetMap) -> [MValuationCashflow] {
        map.reduce(into: []) { array, entry in
            let (accountAssetKey, amount) = entry
            guard accountAssetKey.assetKey != MAsset.cashAssetKey,
                  let accountID = accountMap[accountAssetKey.accountKey]?.accountID,
                  let assetID = assetMap[accountAssetKey.assetKey]?.assetID
            else { return }
            array.append(.init(transactedAt: timestamp,
                                              accountID: accountID,
                                              assetID: assetID,
                                              amount: amount))
        }
    }
}

// MARK: - Consolidation

extension MValuationCashflow {
    
    /// There may be multiple cashflows sharing the same primary key (transactedAt, accountKey, assetID).
    ///
    /// Here we consolidate them so the keys are unique. The amounts are summed.
    /// Result is ordered.
    ///
    /// Cashflows with net sum of zero are omitted.
    internal static func consolidateCashflows(_ cashflows: [MValuationCashflow],
                                              epsilon: Double = 0.01) -> CashflowMap {
        let grouped: [CashflowKey: [MValuationCashflow]] = Dictionary(grouping: cashflows, by: { $0.primaryKey })
        return grouped.reduce(into: [:]) { map, entry in
            let (key, cashflows) = entry
            guard let accountID = cashflows.first?.accountID,
                  let assetID = cashflows.first?.assetID
            else { return }
            let netAmount = cashflows.reduce(0) { $0 + $1.amount }
            guard netAmount.isNotEqual(to: 0, accuracy: epsilon) else { return }
            map[key] = .init(transactedAt: key.transactedAt,
                             accountID: accountID,
                             assetID: assetID,
                             amount: netAmount)
        }
    }
}
