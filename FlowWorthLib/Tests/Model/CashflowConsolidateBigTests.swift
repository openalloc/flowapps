//
//  CashflowConsolidateBigTests.swift
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

class CashflowConsolidateBigTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var model: BaseModel!
    var ax: WorthContext!
    var period: DateInterval!
    var startValue: Double!
    var endValue: Double!
    
    public typealias MD = ModifiedDietz<Double>
    
    let ss: [(String, String)] = [
        ("27B5C5A9-06C6-4E54-A7CF-C7E2A83C4BA9", "2021-07-30T18:26:00Z"),
        ("3BEF862E-717F-468C-80CA-44E913D0E574", "2021-08-19T15:44:00Z"),
        ("05EAE8FE-55F9-4634-945E-0643D1A97ADA", "2021-08-30T16:31:00Z"),
        ("5A150169-842A-4EBC-B88C-A6ECD9C1CE19", "2021-09-16T04:51:00Z"),
        ("51143F17-1818-4329-B7F5-4A70972D095A", "2021-09-29T03:14:00Z"),
        ("2CCEFB81-990C-4A43-AF4D-A11A2F7719E9", "2021-09-30T18:57:00Z"),
        ("7FB93834-F95C-43AE-A9F7-C945CFFDA1DD", "2021-10-28T04:49:00Z"),
        ("DA13E027-4485-4577-AA1F-2C9EC0C6634B", "2021-10-29T19:00:00Z"),
        ("DC9BC3E2-2532-4CE9-B57B-8839366920C8", "2021-11-30T20:29:00Z"),
        ("C4DE3F54-6453-4C23-BF52-01CF5547C9BA", "2021-12-11T06:25:00Z"),
        ("3A372EEA-677E-46EF-85D9-59FF93CFB132", "2021-12-31T17:24:00Z"),
        ("B2E7490C-B30A-427D-BCED-ADF12D85BDA8", "2022-01-31T19:37:00Z"),
    ]
    
    // Positions
    let sp: [(String, String, String, Double, Double)] = [
        ("27B5C5A9-06C6-4E54-A7CF-C7E2A83C4BA9", "212345678", "ITGov", 16192.008360000000, 16485.44642),
        ("3BEF862E-717F-468C-80CA-44E913D0E574", "212345678", "ITGov", 155839.07456      , 155747.95392000000),
        ("05EAE8FE-55F9-4634-945E-0643D1A97ADA", "212345678", "ITGov", 155839.07456      , 155599.88288000000),
        ("5A150169-842A-4EBC-B88C-A6ECD9C1CE19", "212345678", "ITGov", 158843.23130000000, 158402.06460000000),
        ("51143F17-1818-4329-B7F5-4A70972D095A", "212345678", "ITGov", 158843.23130000000, 156590.95920000000),
        ("2CCEFB81-990C-4A43-AF4D-A11A2F7719E9", "212345678", "ITGov", 158843.23130000000, 156776.7136),
        ("7FB93834-F95C-43AE-A9F7-C945CFFDA1DD", "212345678", "ITGov", 153435.4665       , 150431.76270000000),
        ("DA13E027-4485-4577-AA1F-2C9EC0C6634B", "212345678", "ITGov", 153435.4665       , 150230.0214),
        ("DC9BC3E2-2532-4CE9-B57B-8839366920C8", "212345678", "ITGov", 143919.16770000000, 141304.55565),
        ("C4DE3F54-6453-4C23-BF52-01CF5547C9BA", "212345678", "ITGov", 249887.01200000000, 245918.21828000000),
        ("3A372EEA-677E-46EF-85D9-59FF93CFB132", "212345678", "ITGov", 249887.01200000000, 244648.93925140000),
        ("B2E7490C-B30A-427D-BCED-ADF12D85BDA8", "212345678", "ITGov", 132989.12502      , 128892.9103),
    ]
    
    // Cashflow
    let cf: [(String, String, String, Double)] = [
        ("2021-07-30T18:27:00Z", "212345678", "ITGov", 139649.77515),
        ("2021-08-05T18:00:00Z", "212345678", "ITGov", -153.54),
        ("2021-08-30T18:00:00Z", "212345678", "ITGov", 3000.20448),
        ("2021-09-07T18:00:00Z", "212345678", "ITGov", -150.46),
        ("2021-09-30T18:58:00Z", "212345678", "ITGov", -5426.7108),
        ("2021-10-06T18:00:00Z", "212345678", "ITGov", -136.74),
        ("2021-10-29T19:01:00Z", "212345678", "ITGov", -9489.058800000000),
        ("2021-11-04T18:00:00Z", "212345678", "ITGov", -128.74),
        ("2021-11-30T20:30:00Z", "212345678", "ITGov", 105962.84151000000),
        ("2021-12-06T19:00:00Z", "212345678", "ITGov", -225.27),
        ("2021-12-29T19:00:00Z", "212345678", "ITGov", -231.15),
    ]

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        model = BaseModel()
        
        
        model.valuationSnapshots = ss.map {
            MValuationSnapshot(snapshotID: $0.0, capturedAt: df.date(from: $0.1)!)
        }
        
        model.valuationPositions = sp.map {
            MValuationPosition(snapshotID: $0.0, accountID: $0.1, assetID: $0.2, totalBasis: $0.3, marketValue: $0.4)
        }
        
        model.valuationCashflows = cf.map {
            MValuationCashflow(transactedAt: df.date(from: $0.0)!, accountID: $0.1, assetID: $0.2, amount: $0.3)
        }
        
        ax = WorthContext(model)
        
        let firstSS = ax.firstSnapshot!
        let lastSS = ax.lastSnapshot!
        
        period = DateInterval(start: firstSS.capturedAt, end: lastSS.capturedAt)
        
        let firstPositions = ax.snapshotPositionsMap[firstSS.primaryKey]!
        let lastPositions = ax.snapshotPositionsMap[lastSS.primaryKey]!
        
        startValue = firstPositions.first!.marketValue
        endValue = lastPositions.first!.marketValue
    }
    
    // calculate performance across all snapshots
    func getMD() -> MD {
        let cashflowMap = MValuationCashflow.getCashflowMap(ax.orderedCashflow)
        return MD.init(period: period,
                       startValue: startValue,
                       endValue: endValue,
                       cashflowMap: cashflowMap)!
    }
   
    func testBasic() {
        let mdPre = getMD()
    
        let snapshotBaselineMap =  MValuationCashflow.getSnapshotBaselineMap(snapshotKeys: ax.orderedSnapshotKeys,
                                                                             snapshotDateIntervalMap: ax.snapshotDateIntervalMap,
                                                                             snapshotPositionsMap: ax.snapshotPositionsMap,
                                                                             snapshotCashflowsMap: ax.snapshotCashflowsMap)
        model.consolidateCashflow(snapshotBaselineMap: snapshotBaselineMap, accountMap: ax.accountMap, assetMap: ax.assetMap)
        ax = WorthContext(model)  // rebuild the context
        
        let mdPost = getMD()
        
        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
}
