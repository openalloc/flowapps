//
//  AllocMiscTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowBase
import AllocData
import FlowXCT

@testable import FlowAllocLow

final class AllocMiscTests: XCTestCase {
    
    let bond = MAsset.Key(assetID: "Bond")
    let lc = MAsset.Key(assetID: "LC")
    let cash = MAsset.Key(assetID: "Cash")
    let gold = MAsset.Key(assetID: "Gold")

    func testBasic() throws {
        let accountsCSV = """
        accountID,title,isTaxable,canTrade
        1003,CashMgmt,true,false
        1001,Brokerage,true,true
        1002,IRA,false,true
        """
  
        let allocationsCSV = """
        allocationStrategyID,allocationAssetID,targetPct,isLocked
        MyAlloc,LC,0.5,false
        MyAlloc,Bond,0.3,false
        MyAlloc,Gold,0.1,false
        MyAlloc,Cash,0.1,false
        """
        
        let strategiesCSV = """
        strategyID,title
        MyAlloc,My Portfolio Allocation
        """
        
        let assetsCSV = """
        assetID,title,colorCode,parentAssetID
        LC,Large Cap Blend,137,Total
        Bond,Aggregate Bonds,125,
        Gold,Gold,117,
        Cash,Cash & Cash Equivalent,120,
        Total,Total Market,136,
        """
        
        let holdingsCSV = """
        holdingAccountID,holdingSecurityID,holdingLotID,shareCount,shareBasis,acquiredAt
        1003,CORE,,7500.0,1.0
        1001,IAU,,220.0,34.0
        1001,SPY,,87.0,430.0
        1001,AGG,,194.0,116.0
        1002,GLD,,15.0,168.0
        1002,VOO,,31.0,396.0
        1002,BND,,87.0,86.0
        """
        
        let securitiesCSV = """
        securityID,securityAssetID,sharePrice,updatedAt,securityTrackerID
        CORE,Cash,1.0,2021-07-08,
        IAU,Gold,34.0,2021-07-08,
        SPY,LC,430.0,2021-07-08,
        AGG,Bond,116.0,2021-07-08,
        GLD,Gold,168.0,2021-07-08,
        VOO,LC,396.0,2021-07-08,
        BND,Bond,86.0,2021-07-08,
        """

        var model = BaseModel()
        
        //var rr = [AllocRowed.DecodedRow]()
        for csv in [accountsCSV, allocationsCSV, strategiesCSV, assetsCSV, holdingsCSV, securitiesCSV] {
            _ = try model.detectDecodeImport(data: csv.data(using: .utf8)!, url: URL(fileURLWithPath: "foo.csv"))
        }
        
        let allocs = AssetValue.getAssetValues(allocations: model.allocations)
        let flowMode = 0.0  // mirror
        let account1 = MAccount.Key(accountID: "1001")
        let account2 = MAccount.Key(accountID: "1002")
        let accountKeys = [account2, account1] //activeAccounts.map(\.primaryKey)
        let accountHoldingsMap = model.makeAccountHoldingsMap()
        let securityMap = model.makeSecurityMap()
        let accountPVMap = MAccount.getAccountPresentValueMap(accountKeys, accountHoldingsMap, securityMap)
        let capacitiesMap = getCapacitiesMap(accountKeys, accountPVMap)
        let assetAccountLimitMap = getAssetAccountLimitMap(accountKeys: accountKeys, baseAllocs: allocs, accountCapacitiesMap: capacitiesMap, accountCapsMap: [:])
        let vertLimitMap = try getAccountUserVertLimitMap(accountKeys: accountKeys, baseAllocs: allocs, accountCapacitiesMap: capacitiesMap, accountCapsMap: [:])
        let userLimitMap = try getAccountUserAssetLimitMap(accountKeys: accountKeys, baseAllocs: allocs, accountCapacitiesMap: capacitiesMap, accountCapsMap: [:])
        
        let actual = try getAccountAllocationMap(allocs: allocs,
                                                 accountKeys: accountKeys,
                                                 allocFlowMode: flowMode,
                                                 assetAccountLimitMap: assetAccountLimitMap,
                                                 accountUserVertLimitMap: vertLimitMap,
                                                 accountUserAssetLimitMap: userLimitMap,
                                                 accountCapacitiesMap: capacitiesMap)
        
        let expected = [
            account1: [ lc: 0.5, gold: 0.1, cash: 0.1, bond: 0.3 ],
            account2: [ lc: 0.5, gold: 0.1, cash: 0.1, bond: 0.3 ]
        ]
        
        XCTAssertEqual(expected[account1]!, actual[account1]!, accuracy: 0.0001)
        XCTAssertEqual(expected[account2]!, actual[account2]!, accuracy: 0.0001)
    }
}
