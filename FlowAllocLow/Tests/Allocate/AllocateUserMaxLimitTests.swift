//
//  AllocateUserMaxLimitTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//

import XCTest

import FlowBase
import AllocData

@testable import FlowAllocLow

class AllocateUserMaxLimitTests: XCTestCase {
    func testGetFlowTarget() {
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 0, allocFlowMode: 0))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 0, allocFlowMode: 1))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 1, allocFlowMode: 0))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 1, allocFlowMode: 1))
        XCTAssertEqual(0, getFlowTarget(targetPct: 1, accountCapacity: 0, allocFlowMode: 0))
        XCTAssertEqual(1, getFlowTarget(targetPct: 1, accountCapacity: 0, allocFlowMode: 1))
        XCTAssertEqual(1, getFlowTarget(targetPct: 1, accountCapacity: 1, allocFlowMode: 1))

        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 0, allocFlowMode: 0.5))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 0.5, allocFlowMode: 0))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0, accountCapacity: 0.5, allocFlowMode: 0.5))
        XCTAssertEqual(0, getFlowTarget(targetPct: 0.5, accountCapacity: 0, allocFlowMode: 0))
        XCTAssertEqual(0.25, getFlowTarget(targetPct: 0.5, accountCapacity: 0, allocFlowMode: 0.5))
        XCTAssertEqual(0.375, getFlowTarget(targetPct: 0.5, accountCapacity: 0.5, allocFlowMode: 0.5))

        XCTAssertEqual(0.703, getFlowTarget(targetPct: 0.75, accountCapacity: 0.75, allocFlowMode: 0.75), accuracy: 0.001)
        XCTAssertEqual(0.656, getFlowTarget(targetPct: 0.75, accountCapacity: 0.75, allocFlowMode: 0.5), accuracy: 0.001)
        XCTAssertEqual(0.375, getFlowTarget(targetPct: 0.75, accountCapacity: 0.5, allocFlowMode: 0), accuracy: 0.001)
        XCTAssertEqual(0.563, getFlowTarget(targetPct: 0.75, accountCapacity: 0.5, allocFlowMode: 0.5), accuracy: 0.001)
        XCTAssertEqual(0.469, getFlowTarget(targetPct: 0.5, accountCapacity: 0.75, allocFlowMode: 0.75), accuracy: 0.001)
        XCTAssertEqual(0.438, getFlowTarget(targetPct: 0.5, accountCapacity: 0.75, allocFlowMode: 0.5), accuracy: 0.001)
    }

    func testSurplusRequired() {
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 0, flowTarget: 0))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 0, flowTarget: 1))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 1, flowTarget: 0))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 1, flowTarget: 1))
        XCTAssertEqual(1, getSurplusRequired(remainingAssetClassCapacity: 1, forwardAssetClassLimit: 0, flowTarget: 0))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 1, forwardAssetClassLimit: 0, flowTarget: 1))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 1, forwardAssetClassLimit: 1, flowTarget: 1))

        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 0, flowTarget: 0.5))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 0.5, flowTarget: 0))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0, forwardAssetClassLimit: 0.5, flowTarget: 0.5))
        XCTAssertEqual(0.5, getSurplusRequired(remainingAssetClassCapacity: 0.5, forwardAssetClassLimit: 0, flowTarget: 0))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.5, forwardAssetClassLimit: 0, flowTarget: 0.5))
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.5, forwardAssetClassLimit: 0.5, flowTarget: 0.5))

        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.75, forwardAssetClassLimit: 0.75, flowTarget: 0.75), accuracy: 0.001)
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.75, forwardAssetClassLimit: 0.75, flowTarget: 0.5), accuracy: 0.001)
        XCTAssertEqual(0.25, getSurplusRequired(remainingAssetClassCapacity: 0.75, forwardAssetClassLimit: 0.5, flowTarget: 0), accuracy: 0.001)
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.75, forwardAssetClassLimit: 0.5, flowTarget: 0.5), accuracy: 0.001)
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.5, forwardAssetClassLimit: 0.75, flowTarget: 0.75), accuracy: 0.001)
        XCTAssertEqual(0, getSurplusRequired(remainingAssetClassCapacity: 0.5, forwardAssetClassLimit: 0.75, flowTarget: 0.5), accuracy: 0.001)
    }

    func testGetUserMaxLimit() {
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 1, surplusRequired: 0))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 1, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 1, accountCapacity: 0, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 1, accountCapacity: 1, surplusRequired: 0))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 0, flowTarget: 1, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 1, flowTarget: 0, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 1, flowTarget: 0, accountCapacity: 0, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 1, flowTarget: 0, accountCapacity: 1, surplusRequired: 0))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 0, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 0, surplusRequired: 1))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 1, surplusRequired: 0))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 1, surplusRequired: 1))

        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0.5, surplusRequired: 0))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0, flowTarget: 0, accountCapacity: 0.5, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0.5, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0.5, accountCapacity: 0, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0, flowTarget: 0.5, accountCapacity: 0.5, surplusRequired: 0))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0, flowTarget: 0.5, accountCapacity: 0.5, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0.5, flowTarget: 0, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0.5, flowTarget: 0, accountCapacity: 0, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0.5, flowTarget: 0, accountCapacity: 0.5, surplusRequired: 0))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0.5, flowTarget: 0, accountCapacity: 0.5, surplusRequired: 0.5))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0.5, flowTarget: 0.5, accountCapacity: 0, surplusRequired: 0))
        XCTAssertEqual(0, getUserMaxLimit(userLimit: 0.5, flowTarget: 0.5, accountCapacity: 0, surplusRequired: 0.5))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0.5, flowTarget: 0.5, accountCapacity: 0.5, surplusRequired: 0))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0.5, flowTarget: 0.5, accountCapacity: 0.5, surplusRequired: 0.5))

        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 1, surplusRequired: 0.25))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 0.25, surplusRequired: 1))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 1, flowTarget: 1, accountCapacity: 0.25, surplusRequired: 0.25))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 1, flowTarget: 0.25, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 1, flowTarget: 0.25, accountCapacity: 1, surplusRequired: 0.25))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 1, flowTarget: 0.25, accountCapacity: 0.25, surplusRequired: 1))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 1, flowTarget: 0.25, accountCapacity: 0.25, surplusRequired: 0.25))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 0.25, flowTarget: 1, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0.25, flowTarget: 1, accountCapacity: 1, surplusRequired: 0.25))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 0.25, flowTarget: 1, accountCapacity: 0.25, surplusRequired: 1))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 0.25, flowTarget: 1, accountCapacity: 0.25, surplusRequired: 0.25))
        XCTAssertEqual(1, getUserMaxLimit(userLimit: 0.25, flowTarget: 0.25, accountCapacity: 1, surplusRequired: 1))
        XCTAssertEqual(0.5, getUserMaxLimit(userLimit: 0.25, flowTarget: 0.25, accountCapacity: 1, surplusRequired: 0.25))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 0.25, flowTarget: 0.25, accountCapacity: 0.25, surplusRequired: 1))
        XCTAssertEqual(0.25, getUserMaxLimit(userLimit: 0.25, flowTarget: 0.25, accountCapacity: 0.25, surplusRequired: 0.25))
    }

    func testHalfCapacityFlow() {
        let flowTarget = getFlowTarget(targetPct: 1,
                                       accountCapacity: 0.5,
                                       allocFlowMode: 1)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 0.5,
                                    flowTarget: flowTarget,
                                    accountCapacity: 0.5,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 0.5)
    }

    func testHalfCapacityMirror() {
        let flowTarget = getFlowTarget(targetPct: 1,
                                       accountCapacity: 0.5,
                                       allocFlowMode: 0)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 0.5,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 0.5)
    }

    func testHalfMirrorHalfTarget() {
        let flowTarget = getFlowTarget(targetPct: 0.5,
                                       accountCapacity: 1,
                                       allocFlowMode: 0.5)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 1,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 1.0)
    }

    func testFullMirrorHalfTarget() {
        let flowTarget = getFlowTarget(targetPct: 0.5,
                                       accountCapacity: 1,
                                       allocFlowMode: 0)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 1,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 1.0)
    }

    func testFullMirrorHalfTargetQuarterCapacity() {
        let flowTarget = getFlowTarget(targetPct: 0.5,
                                       accountCapacity: 0.25,
                                       allocFlowMode: 0)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 0.25,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 0.25)
    }

    func testHalfMirrorQuarterTarget() {
        let flowTarget = getFlowTarget(targetPct: 0.25,
                                       accountCapacity: 1,
                                       allocFlowMode: 0.5)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 1,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 1.0)
    }

    func testForwardLimitIgnored() {
        let flowTarget = getFlowTarget(targetPct: 0.25,
                                       accountCapacity: 1,
                                       allocFlowMode: 0.5)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0.20,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 1,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 0.8)
    }

    func testForwardLimit() {
        let flowTarget = getFlowTarget(targetPct: 0.15,
                                       accountCapacity: 1,
                                       allocFlowMode: 0)
        let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: 1,
                                                 forwardAssetClassLimit: 0.20,
                                                 flowTarget: flowTarget)
        let limit = getUserMaxLimit(userLimit: 1,
                                    flowTarget: flowTarget,
                                    accountCapacity: 1,
                                    surplusRequired: surplusRequired)
        XCTAssertEqual(limit, 0.8)
    }
}
