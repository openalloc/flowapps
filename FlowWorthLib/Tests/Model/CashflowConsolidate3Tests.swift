//
//  CashflowConsolidate3Tests.swift
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
import ModifiedDietz

class CashflowConsolidate3Tests: XCTestCase {
    
    public typealias MD = ModifiedDietz<Double>
    
    var df: ISO8601DateFormatter!
    var timestamp1A: Date!
    var timestamp1B: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var timestamp4: Date!
    var timestamp5: Date!
    var timestamp6: Date!
    var timestamp7: Date!
    var model: BaseModel!
    var ax: WorthContext!
    
    var snapshot1: MValuationSnapshot!
    var snapshot2: MValuationSnapshot!
    var snapshot3: MValuationSnapshot!
    var cashflow1: MValuationCashflow!
    var cashflow2: MValuationCashflow!
    var cashflow3: MValuationCashflow!
    var cashflow4: MValuationCashflow!
    var position1: MValuationPosition!
    var position2: MValuationPosition!
    var position3: MValuationPosition!
    var accountAssetKey: AccountAssetKey!
    var period2: DateInterval!
    var period3: DateInterval!
    var cf2: [MValuationCashflow]!
    var cf3: [MValuationCashflow]!
    var cfm2: [Date: Double]!
    var cfm3: [Date: Double]!
    var ncf2: Double = 0
    var ncf3: Double = 0
    var md2: MD!
    var md3: MD!
    var expected2: MyBaseline!
    var expected3: MyBaseline!
    var snapshotBaselineMap: SnapshotAccountAssetBaselineMap!
    var mdPre: MD!
    var mdPost: MD!
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1A = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp1B = df.date(from: "2020-06-01T12:00:01Z")!
        timestamp2 = df.date(from: "2020-06-15T12:00:00Z")!
        timestamp3 = df.date(from: "2020-06-20T12:00:00Z")!
        timestamp4 = df.date(from: "2020-06-30T12:00:00Z")!
        timestamp5 = df.date(from: "2020-07-10T12:00:00Z")!
        timestamp6 = df.date(from: "2020-07-22T12:00:00Z")!
        timestamp7 = df.date(from: "2020-07-31T12:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
        
        snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1A)
        snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)
        snapshot3 = MValuationSnapshot(snapshotID: "3", capturedAt: timestamp7)
        position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1600)
        position3 = MValuationPosition(snapshotID: "3", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 2000)
        
        accountAssetKey = AccountAssetKey(accountID: "1", assetID: "Bond")
        period2 = DateInterval(start: timestamp1A, end: timestamp4)
        period3 = DateInterval(start: timestamp4, end: timestamp7)
        cf2 = []
        cf3 = []
        cfm2 = [:]
        cfm3 = [:]
        ncf2 = 0
        ncf3 = 0
        snapshotBaselineMap = [:]
    }
    
    func preConsolidateSetup() {
        model.valuationSnapshots = [snapshot1, snapshot2, snapshot3]
        model.valuationCashflows = [cashflow1, cashflow2, cashflow3, cashflow4]
        model.valuationPositions = [position1, position2, position3]
        ax = WorthContext(model)
        
        cf2 = [cashflow1, cashflow2]
        cf3 = [cashflow3, cashflow4]
        cfm2 = MValuationCashflow.getCashflowMap(cf2)
        cfm3 = MValuationCashflow.getCashflowMap(cf3)
        ncf2 = MValuationCashflow.getNetCashflow(cf2)
        ncf3 = MValuationCashflow.getNetCashflow(cf3)
        
        md2 = MD.init(period: period2, startValue: position1.marketValue, endValue: position2.marketValue, cashflowMap: cfm2)!
        md3 = MD.init(period: period3, startValue: position2.marketValue, endValue: position3.marketValue, cashflowMap: cfm3)!
        
        expected2 = MyBaseline(period: period2,
                               performance: md2.performance,
                               startValue: position1.marketValue,
                               endValue: position2.marketValue,
                               netCashflow: ncf2)
        
        expected3 = MyBaseline(period: period3,
                               performance: md3.performance,
                               startValue: position2.marketValue,
                               endValue: position3.marketValue,
                               netCashflow: ncf3)
        
        snapshotBaselineMap = MValuationCashflow.getSnapshotBaselineMap(snapshotKeys: ax.orderedSnapshotKeys,
                                                                        snapshotDateIntervalMap: ax.snapshotDateIntervalMap,
                                                                        snapshotPositionsMap: ax.snapshotPositionsMap,
                                                                        snapshotCashflowsMap: ax.snapshotCashflowsMap)
        
        mdPre = getMD()
    }
    
    func postConsolidateSetup() {
        model.consolidateCashflow(snapshotBaselineMap: snapshotBaselineMap, accountMap: ax.accountMap, assetMap: ax.assetMap)
        ax = WorthContext(model)  // rebuild the context
        
        mdPost = getMD()
    }
    
    // calculate performance across all snapshots
    func getMD() -> MD {
        let cashflowMap = MValuationCashflow.getCashflowMap(ax.orderedCashflow)
        return MD.init(period: DateInterval(start: timestamp1A, end: timestamp7),
                       startValue: position1.marketValue,
                       endValue: position3.marketValue,
                       cashflowMap: cashflowMap)!
    }
    
    func testA() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50) // +50 for snapshot
        cashflow3 = MValuationCashflow(transactedAt: timestamp5, accountID: "1", assetID: "Bond", amount: -200)
        cashflow4 = MValuationCashflow(transactedAt: timestamp6, accountID: "1", assetID: "Bond", amount: 50) // -150 for snapshot
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1809, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // generate a expected baseline for SECOND snapshot (which is SKIPPED because ncf==0)
        XCTAssertEqual(0.3719, md3.performance, accuracy: 0.0001)
        XCTAssertEqual(0.1935, expected3.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.1935, expected3.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(-100.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(200.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-20, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1880, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0.1064, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2],
                                                         snapshot3.primaryKey: [accountAssetKey: expected3]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(2, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let expectedCF2 = MValuationCashflow(transactedAt: expected3.netDate, accountID: "1", assetID: "Bond", amount: ncf3)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        XCTAssertEqual(expectedCF2.primaryKey, cfItems[1].primaryKey)
        XCTAssertEqual(expectedCF2.amount, cfItems[1].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(-100.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(200.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-20, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1880, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0.1064, mdPost.performance, accuracy: 0.0001)
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testB() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        cashflow3 = MValuationCashflow(transactedAt: timestamp5, accountID: "1", assetID: "Bond", amount: -300)
        cashflow4 = MValuationCashflow(transactedAt: timestamp6, accountID: "1", assetID: "Bond", amount: 45)
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1809, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // generate a expected baseline for SECOND snapshot
        XCTAssertEqual(0.4646, md3.performance, accuracy: 0.0001)
        XCTAssertEqual(0.2542, expected3.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.2542, expected3.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(-205.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(305.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-55.74, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1844.25, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0.1654, mdPre.performance, accuracy: 0.0001)
                
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2],
                                                         snapshot3.primaryKey: [accountAssetKey: expected3]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(2, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let expectedCF2 = MValuationCashflow(transactedAt: expected3.netDate, accountID: "1", assetID: "Bond", amount: ncf3)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        XCTAssertEqual(expectedCF2.primaryKey, cfItems[1].primaryKey)
        XCTAssertEqual(expectedCF2.amount, cfItems[1].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(-205.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(305.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-55.75, mdPost.adjustedNetCashflow, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(1844.25, mdPost.averageCapital, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(0.1654, mdPost.performance, accuracy: 0.0001)
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testWhereThirdHas0NCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        cashflow3 = MValuationCashflow(transactedAt: timestamp5, accountID: "1", assetID: "Bond", amount: -200) // cancel each other out
        cashflow4 = MValuationCashflow(transactedAt: timestamp6, accountID: "1", assetID: "Bond", amount: 200) // cancel each other out
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1809, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // generate a expected baseline for SECOND snapshot (which is SKIPPED because ncf==0)
        XCTAssertEqual(0.2627, md3.performance, accuracy: 0.0001)
        XCTAssertEqual(1.0, expected3.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(1.0, expected3.weight, accuracy: 0.0001) // this was nil before
        
        // PRE-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(50.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(50.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(2.5, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1902.5, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0.0263, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2]]
        //snapshot3.primaryKey: [accountAssetKey: expected3]] skipped because ncf==0
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(1, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        //let expectedCF2 = MValuationCashflow(transactedAt: expected3.netDate, accountID: "1", assetID: "Bond", amount: ncf3)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        //XCTAssertEqual(expectedCF2.primaryKey, cfItems[1].primaryKey)
        //XCTAssertEqual(expectedCF2.amount, cfItems[1].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(50.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(50.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(42.5, mdPost.adjustedNetCashflow, accuracy: 0.01) // diff than pre
        XCTAssertEqual(1942.5, mdPost.averageCapital, accuracy: 0.01) // diff than pre
        XCTAssertEqual(0.0257, mdPost.performance, accuracy: 0.0001) // diff than pre
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testWithOverall0NCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        cashflow3 = MValuationCashflow(transactedAt: timestamp5, accountID: "1", assetID: "Bond", amount: -200)
        cashflow4 = MValuationCashflow(transactedAt: timestamp6, accountID: "1", assetID: "Bond", amount: 150) // all cancel each other out
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1809, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // generate a expected baseline for SECOND snapshot (which is SKIPPED because ncf==0)
        XCTAssertEqual(0.2984, md3.performance, accuracy: 0.0001)
        XCTAssertEqual(-0.8387, expected3.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.0, expected3.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(0.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(100.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-5, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1895, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0.0528, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2],
                                                         snapshot3.primaryKey: [accountAssetKey: expected3]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(2, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let expectedCF2 = MValuationCashflow(transactedAt: expected3.netDate, accountID: "1", assetID: "Bond", amount: ncf3)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        XCTAssertEqual(expectedCF2.primaryKey, cfItems[1].primaryKey)
        XCTAssertEqual(expectedCF2.amount, cfItems[1].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(0.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(100.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(16.67, mdPost.adjustedNetCashflow, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(1916.67, mdPost.averageCapital, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(0.0522, mdPost.performance, accuracy: 0.0001) // diff from Pre
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testOverallPerformanceOf0AndZeroCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        cashflow3 = MValuationCashflow(transactedAt: timestamp5, accountID: "1", assetID: "Bond", amount: -200)
        cashflow4 = MValuationCashflow(transactedAt: timestamp6, accountID: "1", assetID: "Bond", amount: 150) // all cancel each other out
        
        // override default positions
        position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 2100)
        position3 = MValuationPosition(snapshotID: "3", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)

        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(0.0775, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // generate a expected baseline for SECOND snapshot (which is SKIPPED because ncf==0)
        XCTAssertEqual(-0.0747, md3.performance, accuracy: 0.0001)
        XCTAssertEqual(-0.8387, expected3.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.0, expected3.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(0.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-5, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1895, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2],
                                                         snapshot3.primaryKey: [accountAssetKey: expected3]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(2, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let expectedCF2 = MValuationCashflow(transactedAt: expected3.netDate, accountID: "1", assetID: "Bond", amount: ncf3)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        XCTAssertEqual(expectedCF2.primaryKey, cfItems[1].primaryKey)
        XCTAssertEqual(expectedCF2.amount, cfItems[1].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across both snapshots
        XCTAssertEqual(0.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(16.67, mdPost.adjustedNetCashflow, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(1916.67, mdPost.averageCapital, accuracy: 0.01) // diff from Pre
        XCTAssertEqual(0, mdPost.performance, accuracy: 0.0001) // diff from Pre
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
}
