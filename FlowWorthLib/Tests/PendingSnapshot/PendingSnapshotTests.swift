//
//  PendingSnapshotTests.swift
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

class PendingSnapshotTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp3a: Date!
    var model: BaseModel!
    var ax: WorthContext!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        timestamp2b = df.date(from: "2020-06-03T00:00:01Z")! // one day, 12 hours and one second later
        timestamp3a = df.date(from: "2020-06-03T06:00:00Z")! // one day beyond start of day (for 2a)
        model = BaseModel()
        ax = WorthContext(model)
    }

    func testEmpty() throws {
        XCTAssertEqual(0, model.valuationSnapshots.count)
        let pending = PendingSnapshot(timestamp: timestamp1a)
        try model.commitPendingSnapshot(pending)
        XCTAssertEqual(1, model.valuationSnapshots.count)
        XCTAssertEqual(model.valuationSnapshots[0].capturedAt, timestamp1a)
        XCTAssertEqual(model.valuationSnapshots[0].snapshotID, pending.snapshotID)
    }
    
    func testPrimaryKeyConflict() throws {
        XCTAssertEqual(0, model.valuationSnapshots.count)
        let pending1 = PendingSnapshot(timestamp: timestamp1a)
        try model.commitPendingSnapshot(pending1)
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: pending1.snapshotID)
        XCTAssertThrowsError(try model.commitPendingSnapshot(pending2)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.cannotCreateSnapshot("A snapshot already exists with that ID."))
        }
    }
    
    // because history record transactedAt don't specify time of day, don't allow two snapshots in same day
    func testDisallowSameDaySnapshot() throws {
        
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let security = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let strategy = MStrategy(strategyID: "S")
        let account = MAccount(accountID: "1", title: "X", strategyID: "S")
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "U", shareCount: 5, shareBasis: 7)
    
        model.assets = [asset]
        model.securities = [security]
        model.strategies = [strategy]
        model.accounts = [account]
        model.holdings = [holding]

        ax = WorthContext(model)

        let pending1 = PendingSnapshot(timestamp: timestamp1a, holdings: [holding], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationSnapshots.count)
        XCTAssertEqual(1, model.valuationPositions.count)
        XCTAssertEqual(0, model.holdings.count)
        
        model.holdings = [holding]
        ax = WorthContext(model) // refresh

        let pending2 = PendingSnapshot(timestamp: timestamp1b, previousSnapshot: ax.lastSnapshot)
        
        XCTAssertThrowsError(try model.commitPendingSnapshot(pending2)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.cannotCreateSnapshot("Only one snapshot per 24 hour period."))
        }
    }

    func testOneValidHolding() throws {
        XCTAssertEqual(0, model.holdings.count)
        XCTAssertEqual(0, model.valuationSnapshots.count)
        XCTAssertEqual(0, model.valuationPositions.count)
        //XCTAssertEqual(0, model.valuationTxns.count)
        
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let security = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let strategy = MStrategy(strategyID: "S")
        let account = MAccount(accountID: "1", title: "X", strategyID: "S")
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "U", shareCount: 5, shareBasis: 7)
    
        model.assets = [asset]
        model.securities = [security]
        model.strategies = [strategy]
        model.accounts = [account]
        model.holdings = [holding]

        ax = WorthContext(model)

        let pending = PendingSnapshot(timestamp: timestamp1a, holdings: [holding], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending)
        XCTAssertEqual(1, model.valuationSnapshots.count)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        let pos = model.valuationPositions[0]
        XCTAssertEqual(pos.snapshotID, pending.snapshotID)
        XCTAssertEqual(pos.accountID, holding.accountID)
        XCTAssertEqual(pos.assetID, security.assetID)
        XCTAssertEqual(pos.totalBasis, holding.shareCount! * holding.shareBasis!)
        XCTAssertEqual(pos.marketValue, holding.shareCount! * security.sharePrice!)
        XCTAssertTrue(pos.totalBasis > 0)
        XCTAssertTrue(pos.marketValue > 0)

        XCTAssertEqual(0, model.holdings.count) // ensure holding was cleared
    }
    
    func testOneNegativeHolding() throws {
        XCTAssertEqual(0, model.holdings.count)
        XCTAssertEqual(0, model.valuationSnapshots.count)
        XCTAssertEqual(0, model.valuationPositions.count)
        //XCTAssertEqual(0, model.valuationTxns.count)
        
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let security = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let strategy = MStrategy(strategyID: "S")
        let account = MAccount(accountID: "1", title: "X", strategyID: "S")
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "U", shareCount: -5, shareBasis: 7)
    
        model.assets = [asset]
        model.securities = [security]
        model.strategies = [strategy]
        model.accounts = [account]
        model.holdings = [holding]

        ax = WorthContext(model)

        let pending = PendingSnapshot(timestamp: timestamp1a, holdings: [holding], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending)
        XCTAssertEqual(1, model.valuationSnapshots.count)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        let pos = model.valuationPositions[0]
        XCTAssertEqual(pos.snapshotID, pending.snapshotID)
        XCTAssertEqual(pos.accountID, holding.accountID)
        XCTAssertEqual(pos.assetID, security.assetID)
        XCTAssertEqual(pos.totalBasis, holding.shareCount! * holding.shareBasis!)
        XCTAssertEqual(pos.marketValue, holding.shareCount! * security.sharePrice!)
        XCTAssertTrue(pos.totalBasis < 0)
        XCTAssertTrue(pos.marketValue < 0)
        
        XCTAssertEqual(0, model.holdings.count) // ensure holding was cleared
    }

    func testNoHoldingsOneTransaction() throws {
        
        // Assume the holding was sold off prior to snapshot.
        // The history item is ignored, because the share count goal was met.
        
        XCTAssertEqual(0, model.transactions.count)
        //XCTAssertEqual(0, model.valuationTxns.count)
        
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let security = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let strategy = MStrategy(strategyID: "S")
        let account = MAccount(accountID: "1", title: "X", strategyID: "S")
        let txn = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "1", securityID: "BND", shareCount: 5, sharePrice: 3)
        let snapshot = MValuationSnapshot(snapshotID: "V", capturedAt: timestamp1a)
        
        model.assets = [asset]
        model.securities = [security]
        model.strategies = [strategy]
        model.accounts = [account]
        model.transactions = [txn]
        model.valuationSnapshots = [snapshot]
        
        ax = WorthContext(model)
        
        let pending = PendingSnapshot(timestamp: timestamp2a, transactions: [txn], assetMap: ax.assetMap, securityMap: ax.securityMap)
        XCTAssertEqual(timestamp2a, pending.snapshot.capturedAt)
        //XCTAssertEqual([], pending.nuValuationTxns)
        XCTAssertEqual([], pending.nuCashflows)
        XCTAssertEqual([], pending.nuPositions)
    }
    
    func testInvalidSecurityForHolding() throws {
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let strategy = MStrategy(strategyID: "S")
        let account = MAccount(accountID: "1", title: "X", strategyID: "S")
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "U", shareCount: 5, shareBasis: 7)
        model.assets = [asset]
        model.strategies = [strategy]
        model.accounts = [account]
        model.holdings = [holding]
        ax = WorthContext(model)
        let pending = PendingSnapshot(timestamp: timestamp1a, holdings: [holding], assetMap: ax.assetMap, securityMap: ax.securityMap)
        XCTAssertThrowsError(try model.commitPendingSnapshot(pending)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidSecurity(holding.securityID))
        }
        XCTAssertEqual(0, model.valuationSnapshots.count)
    }
    
    //TODO test to show that securities purchased halfway through the month don't show up in recon cash flow
}
