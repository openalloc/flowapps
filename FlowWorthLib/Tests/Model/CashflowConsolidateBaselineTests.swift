//
//  CashflowConsolidateBaselineTests.swift
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

class CashflowConsolidateBaselineTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestampA0: Date!
    var timestampA1: Date!
    var timestampB0: Date!
    var timestampB1: Date!
    var timestampC0: Date!
    var timestampC1: Date!
    var timestampD0: Date!
    var timestampD1: Date!
    var timestampE0: Date!
    var model: BaseModel!
    var ax: WorthContext!
    
    typealias MD = ModifiedDietz<Double>
    typealias DateMV = (date: Date, mv: Double)
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestampA0 = df.date(from: "2020-06-01T12:00:00Z")!
        timestampA1 = df.date(from: "2020-06-01T12:00:01Z")!
        timestampB0 = df.date(from: "2020-06-15T12:00:00Z")!
        timestampB1 = df.date(from: "2020-06-15T12:00:01Z")!
        timestampC0 = df.date(from: "2020-06-20T12:00:00Z")!
        timestampC1 = df.date(from: "2020-06-20T12:00:01Z")!
        timestampD0 = df.date(from: "2020-06-30T12:00:00Z")!
        timestampD1 = df.date(from: "2020-06-30T12:00:01Z")!
        timestampE0 = df.date(from: "2020-07-01T12:00:01Z")!
        model = BaseModel()
        ax = WorthContext(model)
    }
    
    /// helper func which validates performance before and after moving to single cashflow
    func verifyBaseline(beg: DateMV, end: DateMV, cfMap: MD.CashflowMap, accuracy: Double = 0.0001) -> MyBaseline? {
        let period = DateInterval(start: beg.date, end: end.date)
        
        // determine target performance (R)
        guard let md1 = MD.init(period: period,
                                startValue: beg.mv,
                                endValue: end.mv,
                                cashflowMap: cfMap)
        else { XCTFail("bad md1"); return nil }
        
        //print("Performance: \(md1.performance.percent3())")
        
        let cfNet = md1.netCashflowTotal // this excludes CF outside the period
        //cfMap.values.reduce(0, +)
        
        // determine the 'baseline' for a given R and cashflow
        let b = MyBaseline(period: period,
                           performance: md1.performance,
                           startValue: beg.mv,
                           endValue: end.mv,
                           netCashflow: cfNet)
        guard b.weight.isFinite else { XCTFail("weight not finite: \(b.weight)"); return nil }
        guard b.weight.isGreaterThanOrEqual(to: 0, accuracy: 0.0001),
              b.weight.isLessThanOrEqual(to: 1, accuracy: 0.0001)
        else { XCTFail("weight out of unit range: \(b.weight)"); return nil }
        //guard let netDate = b.netDate else { XCTFail("netDate is nil"); return nil }
        
        //print("Weight: \(b.w.format3())")
        //print("Net Date: \(b.netDate == nil ? "nil" : df.string(from: b.netDate))")
        
        // verify that a SINGLE cashflow at NETDATE produces the same R
        guard let md2 = MD.init(period: period,
                                startValue: beg.mv,
                                endValue: end.mv,
                                cashflowMap: [b.netDate: cfNet])
        else { XCTFail("bad md2"); return nil }
        
        XCTAssertEqual(md1.performance, md2.performance, accuracy: accuracy,
                       "Expecting performance \(md1.performance.percent3()), but was \(md2.performance.percent3())")
        
        return b
    }
    
    // Explicit test (no helper function)
    func testExplicit1() throws {
        let period = DateInterval(start: timestampA0, end: timestampD0)
        let cashflow1 = MValuationCashflow(transactedAt: timestampB0, accountID: "1", assetID: "Bond", amount: 100)
        let cashflow2 = MValuationCashflow(transactedAt: timestampC0, accountID: "1", assetID: "Bond", amount: -50)
        let position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        let position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1600)
        
        let cashflows = [cashflow1, cashflow2]
        let cashflowMap = MValuationCashflow.getCashflowMap(cashflows)
        let netCashflow = MValuationCashflow.getNetCashflow(cashflows)
        
        // determine the expected performance
        let md1 = MD.init(period: period,
                          startValue: position1.marketValue,
                          endValue: position2.marketValue,
                          cashflowMap: cashflowMap)!
        XCTAssertEqual(-0.1809, md1.performance, accuracy: 0.0001)
        
        let b = MyBaseline(period: period,
                           performance: md1.performance,
                           startValue: position1.marketValue,
                           endValue: position2.marketValue,
                           netCashflow: netCashflow)
        XCTAssertEqual(0.3103, b.weight, accuracy: 0.0001)
        assertEqual(df.date(from: "2020-06-10T12:00:00Z"), b.netDate, accuracy: 1)
        
        // verify the baseline produced the desired performance
        let md2 = MD.init(period: period,
                          startValue: position1.marketValue,
                          endValue: position2.marketValue,
                          cashflowMap: [b.netDate: netCashflow])!
        XCTAssertEqual(md1.performance, md2.performance, accuracy: 0.0001)
    }

    // is it possible to generate a SINGLE cashflow WITHIN the period with the same performance and netCashflow?
    func testExplicit2() throws {
        let period = DateInterval(start: timestampA0, end: timestampD0)
        let performance = -0.1579
        let startValue = 1900.0
        let endValue = 1600.0
        let netCashflow = 50.0
        
        // performance if at BEGINNING and END of period
        let mdStart = MD.init(period: period,
                              startValue: startValue,
                              endValue: endValue,
                              cashflowMap: [period.start: netCashflow])!
        XCTAssertEqual(performance, mdStart.performance, accuracy: 0.0001) // this works!
        let mdEnd = MD.init(period: period,
                            startValue: startValue,
                            endValue: endValue,
                            cashflowMap: [period.end: netCashflow])!
        XCTAssertEqual(-0.1842, mdEnd.performance, accuracy: 0.0001)
        
        // -5.332 clamped to 0
        let b = MyBaseline(period: period,
                           performance: performance,
                           startValue: startValue,
                           endValue: endValue,
                           netCashflow: netCashflow)
        XCTAssertEqual(0, b.weight, accuracy: 0.0001)
    }

    // Same as explicit, but using the helper function
    func testBaselineWithHelper() throws {
        let b = verifyBaseline(beg: (timestampA0, 1900), end: (timestampD0, 1600), cfMap: [timestampB0: 100.0, timestampC0: -50.0])
        XCTAssertEqual(0.3103, b!.weight, accuracy: 0.0001)
        XCTAssertEqual(-0.1809, b!.performance, accuracy: 0.0001)
        assertEqual(df.date(from: "2020-06-10T12:00:00Z"), b!.netDate, accuracy: 1)
    }

    // w = 1 - ((1600-150-(1900*(-0.228546 + 1))) / (-0.228546 * 150)) = 0.459
    func testBasic1() throws {
        let b = verifyBaseline(beg: (timestampA0, 1900), end: (timestampD0, 1600), cfMap: [timestampB0: 100.0, timestampC0: 50.0])
        XCTAssertEqual(0.540, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.229, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-17T04:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testBasic2() throws {
        let b = verifyBaseline(beg: (timestampA0, 29988), end: (timestampD0, 3532), cfMap: [timestampB0: 22000.0, timestampC0: -34500.0])
        XCTAssertEqual(0.959, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.474, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-29T07:12:00Z"), b!.netDate, accuracy: 1)
    }
    
    func testMVParityMapDiff() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 100), cfMap: [timestampB0: 0.5, timestampC0: 0.5])
        XCTAssertEqual(0.569, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.010, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-18T00:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testMVDiffMapDiff() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampB0: 1.0, timestampC0: 1.5])
        XCTAssertEqual(0.586, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.965, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-18T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    
    // tests with one timestamp
    func testMVDiffOneCFStart() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampA1: -1.0])
        XCTAssertEqual(0.000, b!.weight, accuracy: 0.001)
        XCTAssertEqual(1.020, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-01T12:00:01Z"), b!.netDate, accuracy: 1)
    }
    func testMVDiffOneCFMidway() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampB0: -1.0])
        XCTAssertEqual(0.483, b!.weight, accuracy: 0.001)
        XCTAssertEqual(1.015, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-15T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testMVDiffOneCFEnd() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampD0: -1.0])
        XCTAssertEqual(1.000, b!.weight, accuracy: 0.001)
        XCTAssertEqual(1.010, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    
    func testMVParityOneCFStart() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 100), cfMap: [timestampA1: -1.0])
        XCTAssertEqual(0.000, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.010, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-01T12:00:01Z"), b!.netDate, accuracy: 1)
    }

    func testMVParityOneCFMidway() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 100), cfMap: [timestampB0: -1.0])
        XCTAssertEqual(0.483, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.010, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-15T12:00:00Z"), b!.netDate, accuracy: 1)
    }

    func testMVParityOneCFEnd() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 100), cfMap: [timestampD0: -1.0])
        XCTAssertEqual(1.000, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.010, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
      
    func testPerformanceOf0() throws {
        let b = verifyBaseline(beg: (timestampA0, -44180), end: (timestampE0, -63854), cfMap: [timestampB0: -19674]) // w=nan
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.000, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-07-01T12:00:00Z"), b!.netDate, accuracy: 1)
    }
        
    func testMVParityMapParity() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 100), cfMap: [timestampB0: 1.0, timestampC0: -1.0]) // w=NaN
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.000, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    
    func testMVDiffNetCF0A() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampB0: 1.0, timestampC0: -1.0], accuracy: 0.002) // w=-inf
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(0.998, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testMVDiffZeroCF() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [:]) // w=nan
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(1.0, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }

    func testMVDiffNetCF0B() throws {
        let b = verifyBaseline(beg: (timestampA0, 200), end: (timestampD0, 100), cfMap: [timestampB0: 1.0, timestampC0: -1.0], accuracy: 0.05) // w=-inf
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.5, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testMVParityZeroCF() throws {
        let b = verifyBaseline(beg: (timestampA0, 200), end: (timestampD0, 100), cfMap: [:]) // w=nan
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.5, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }

    // the timestamps here are OUTSIDE the period (and thus should be ignored)
    func testMVDiffOutsideCF() throws {
        let b = verifyBaseline(beg: (timestampA0, 100), end: (timestampD0, 200), cfMap: [timestampA0: 25, timestampD1: -35]) // w=nan
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(1.0, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    func testMVParityOutsideCF() throws {
        let b = verifyBaseline(beg: (timestampA0, 200), end: (timestampD0, 100), cfMap: [timestampA0: 25, timestampD1: -35]) // w=nan
        XCTAssertEqual(1.0, b!.weight, accuracy: 0.001)
        XCTAssertEqual(-0.5, b!.performance, accuracy: 0.001)
        assertEqual(df.date(from: "2020-06-30T12:00:00Z"), b!.netDate, accuracy: 1)
    }
    
    func testWeightWithGrowth() throws {
        let period = DateInterval(start: timestampA0, end: timestampD0)  // should be exclusive of timestamp1
        let baseline = MyBaseline(period: period,
                                  performance: 0.1809,
                                  startValue: 1600,
                                  endValue: 1900,
                                  netCashflow: 50)
        XCTAssertEqual(1, baseline.weight, accuracy: 0.01)
        XCTAssertEqual(50, baseline.netCashflow)
        
        let expected = timestampD0
        XCTAssertEqual(expected, baseline.netDate)
    }
    
    func testExcludesStartPeriod() throws {
        let period = DateInterval(start: timestampA0, end: timestampD0)  // should be exclusive of timestamp1
        let baseline = MyBaseline(period: period,
                                  performance: -0.1809,
                                  startValue: 1900,
                                  endValue: 1600,
                                  netCashflow: 50)
        XCTAssertEqual(0.305, baseline.weight, accuracy: 0.001)
        XCTAssertEqual(50, baseline.netCashflow)
        let actual = baseline.netDate
        let expected = df.date(from: "2020-06-10T07:59:36Z")
        assertEqual(expected, actual, accuracy: 1)
    }
}
