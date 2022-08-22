//
//  CashflowConsolidate+Exists.swift
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

public extension MValuationCashflow {
    
    // report on whether ANY candidates for consolidation exist (false == no candidates)
    static func consolidateCandidatesExist(_ ax: WorthContext) -> Bool {
        for snapshotKey in ax.orderedSnapshotKeys {
            guard let cashflows = ax.snapshotCashflowsMap[snapshotKey] else { continue }
            let groupedCashflows = Dictionary(grouping: cashflows, by: { $0.accountAssetKey })
            for _cashflows in groupedCashflows.values {
                if _cashflows.count > 1 { return true }
            }
        }
        return false
    }
}

