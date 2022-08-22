//
//  BaseModelDeleteTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest

import AllocData
import FINporter

@testable import FlowBase

class BaseModelDeleteTests: XCTestCase {
    
    // Tests to ensure foreign keys are invalidated
    
    func testInvalidateAccountsFKonStrategyDelete() throws {
        let strategy = MStrategy(strategyID: "1")
        let account = MAccount(accountID: "2", strategyID: "1")
        var model = BaseModel(accounts: [account], strategies: [strategy])
        model.delete(strategy)
        XCTAssertEqual("", model.accounts.first?.strategyID)
    }

    func testInvalidateSecuritysFKonTrackerDelete() throws {
        let tracker = MTracker(trackerID: "1")
        let security = MSecurity(securityID: "2", trackerID: "1")
        var model = BaseModel(securities: [security], trackers: [tracker])
        model.delete(tracker)
        XCTAssertEqual("", model.securities.first?.trackerID)
    }
    
    func testInvalidateParentAssetFK() throws {
        let parent = MAsset(assetID: "1")
        let child = MAsset(assetID: "2", parentAssetID: "1")
        var model = BaseModel(assets: [parent, child])
        model.delete(parent)
        XCTAssertEqual("", model.assets.first?.parentAssetID)
    }

    func testInvalidateSecuritysFKonAssetDelete() throws {
        let asset = MAsset(assetID: "1")
        let security = MSecurity(securityID: "2", assetID: "1")
        var model = BaseModel(assets: [asset], securities: [security])
        model.delete(asset)
        XCTAssertEqual("", model.securities.first?.assetID)
    }

    // TODO tests to ensure cascade deletes
    
}
