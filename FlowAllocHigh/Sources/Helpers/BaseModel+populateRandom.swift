//
//  BaseModel+populateRandom.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import Algorithms
import AllocData

import FlowBase

public extension BasePopulator {
    
    func populateRandom(_ model: inout BaseModel,
                        capsPerAccount: Int = 2,
                        transactionCount: Int = 25,
                        baseSharePrice: Double = 100.0
    ) throws {
        
        model.caps = BasePopulator.getCaps(model, capsPerAccount, randomAsset)
        
        model.transactions = BasePopulator.getTxns(model, transactionCount, randomSecurity, baseSharePrice)
    }
    
    static func getCaps(_ model: BaseModel,
                        _ capsPerAccount: Int, _ randomAsset: () -> MAsset) -> [MCap] {
        return model.accounts.map { account in
            (0 ..< capsPerAccount).compactMap { _ in
                let asset = randomAsset()
                return MCap(accountID: account.accountID, assetID: asset.assetID, limitPct: Double.random(in: 0 ... 1))
            }
        }.flatMap { $0 }
    }
    
    static func getTxns(_ model: BaseModel,
                                _ transactionCount: Int,
                                _ randomSecurity: () -> MSecurity,
                                _ baseSharePrice: Double) -> [MTransaction] {
        return (0 ..< transactionCount).compactMap { n in
            let thirtyDaysBack = getDaysBackMidnight(daysBack: 30, timestamp: Date())!
            let timeInterval = TimeInterval((Int.random(in: 0 ... 10) - 5) * 86400)
            let transactedAt = thirtyDaysBack.addingTimeInterval(timeInterval)
            let shareCount = Double.random(in: -250.0 ... 250.0)
            
            let action: MTransaction.Action = MTransaction.Action.allCases.randomElement() ?? .buysell
            let security = randomSecurity()
            let basePrice = security.sharePrice ?? baseSharePrice
            let sharePrice = getNetSharePrice(basePrice)
            let diff = sharePrice - basePrice
            let realizedShort = diff * Double.random(in: 0 ... 1)
            let realizedLong = diff * Double.random(in: 0 ... 1)
            
            return MTransaction(action: action,
                                transactedAt: transactedAt,
                                accountID: model.accounts.randomElement()!.accountID,
                                securityID: security.securityID,
                                shareCount: shareCount,
                                sharePrice: sharePrice,
                                realizedGainShort: realizedShort,
                                realizedGainLong: realizedLong)
        }
    }
}
