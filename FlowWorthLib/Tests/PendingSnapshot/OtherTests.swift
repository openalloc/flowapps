//
//  OtherTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class OtherTests: XCTestCase {
    //var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp2a: Date!
    
    override func setUpWithError() throws {
        //tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-07-30T07:00:00Z")!
        timestamp1b = df.date(from: "2020-07-30T07:01:00Z")!
        timestamp2a = df.date(from: "2020-08-19T12:00:00Z")!
    }
    
    func testOne() throws {
        let bond = MAsset(assetID: "Bond")
        let cash = MAsset(assetID: MAsset.cashAssetID)
        let vgit = MSecurity(securityID: "VGIT", assetID: "Bond", sharePrice: 69)
        let core = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let account = MAccount(accountID: "1")
        let assetMap: AssetMap = [
            MAsset.Key(assetID: "bond"): bond,
            MAsset.cashAssetKey: cash]
        let accountMap: AccountMap = [MAccount.Key(accountID: "1"): account]
        let securityMap: SecurityMap = [
            MSecurity.Key(securityID: "vgit"): vgit,
            MSecurity.Key(securityID: "core"): core]
        let previousSnapshot = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1a)
        let previousPositions: [MValuationPosition] = [
            MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Cash", totalBasis: 14850, marketValue: 14850),
            MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 26.692*67.32, marketValue: 26.692*68.54) // $1,829
        ]
        let transactions: [MTransaction] = [
            MTransaction(action: .buysell,
                         transactedAt: timestamp1a,
                         accountID: "1",
                         securityID: "VGIT",
                         lotID: "",
                         shareCount: 216.66,
                         sharePrice: 68.54) // +$14,850
        ]
        let holdings = [
            MHolding(accountID: "1", securityID: "VGIT", lotID: "", shareCount: 243.352, shareBasis: 68.41)
        ]
        let pending = PendingSnapshot(snapshotID: "2",
                                      timestamp: timestamp2a,
                                      holdings: holdings, // no cash, $16,791 of VGIT
                                      transactions: transactions, // +$14,850 of VGIT
                                      previousSnapshot: previousSnapshot,
                                      previousPositions: previousPositions, // $14,850 of Cash; $1,829 of VGIT
                                      userExcludedTxnKeys: [],
                                      accountMap: accountMap,
                                      assetMap: assetMap,
                                      securityMap: securityMap)
        
        let expected: [MValuationCashflow] = [
            .init(transactedAt: timestamp1b, accountID: "1", assetID: "Bond", amount: 14849.876400000001), // NOTE clamped to one minute later
            .init(transactedAt: timestamp1b, accountID: "1", assetID: "Cash", amount: -14849.876400000001)
        ]
        
        XCTAssertEqual(expected, pending.nuCashflows)
        XCTAssertEqual(0.0067, pending.periodSummary!.dietz!.performance, accuracy: 0.0001)
    }
}
