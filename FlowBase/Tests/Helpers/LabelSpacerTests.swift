//
//  LabelSpacerTests.swift
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

@testable import FlowBase

class LabelSpacerTests: XCTestCase {
    
    func testEmpty() throws {
        let ls = LabelSpacer(tickPositions: [], availWidth: 0, labelWidth: 0, minSpace: 0)
        XCTAssertEqual(0, ls.halfLabelWidth)
        XCTAssertEqual([], ls.showLabel)
    }
        
    // sufficient width to show zero-width label
    func test1pos0widthLabel() throws {
        let ls = LabelSpacer(tickPositions: [0], availWidth: 0, labelWidth: 0, minSpace: 0)
        XCTAssertEqual([true], ls.showLabel)
    }
    
    // sufficient width to show 1-width label (spills over on both margins)
    func test1pos1widthLabel() throws {
        let ls = LabelSpacer(tickPositions: [0], availWidth: 0, labelWidth: 1, minSpace: 0)
        XCTAssertEqual(0.5, ls.halfLabelWidth)
        XCTAssertEqual([true], ls.showLabel)
    }
    
    // with invalid position
    func testFirstPositionBeyondZeroButInsufficientWidth() throws {
        let ls = LabelSpacer(tickPositions: [1], availWidth: 0, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([false], ls.showLabel)
    }

    func testFirstPositionBeyondZero() throws {
        let ls = LabelSpacer(tickPositions: [1], availWidth: 1, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true], ls.showLabel)
    }
    
    func test2posZeroWidthLabel() throws {
        let ls = LabelSpacer(tickPositions: [0,1], availWidth: 1, labelWidth: 0, minSpace: 0)
        XCTAssertEqual(0, ls.halfLabelWidth)
        XCTAssertEqual([true, true], ls.showLabel)
    }
    
    func test2posNoSpaceForSecondBecausePos() throws {
        let ls = LabelSpacer(tickPositions: [0,0.5], availWidth: 1, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, false], ls.showLabel)
    }

    func test2posOneWidthLabel() throws {
        let ls = LabelSpacer(tickPositions: [0,1], availWidth: 1, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, true], ls.showLabel)
    }

    func test2posNoSpaceForSecondBecauseMinSpace() throws {
        let ls = LabelSpacer(tickPositions: [0,1], availWidth: 1, labelWidth: 1, minSpace: 0.1)
        XCTAssertEqual([true, false], ls.showLabel)
    }
    
    func test2posNoSpaceBecauseStart() throws {
        let ls = LabelSpacer(tickPositions: [0.1,1], availWidth: 1, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, false], ls.showLabel)
    }
    
    func test2posSpaceBecauseEndPushedOut() throws {
        let ls = LabelSpacer(tickPositions: [0.1,1.1], availWidth: 1.1, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, true], ls.showLabel)
    }
    
    func test2posNoSpaceDespiteEndPushedOut() throws {
        let ls = LabelSpacer(tickPositions: [0.1,1.1], availWidth: 1.1, labelWidth: 1, minSpace: 0.1)
        XCTAssertEqual([true, false], ls.showLabel)
    }

    func test2posSpaceWithEndPushedOut() throws {
        let ls = LabelSpacer(tickPositions: [0.1,1.2], availWidth: 1.2, labelWidth: 1, minSpace: 0.1)
        XCTAssertEqual([true, true], ls.showLabel)
    }
    
    func test3pos() throws {
        let ls = LabelSpacer(tickPositions: [0,1,2], availWidth: 2, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, true, true], ls.showLabel)
    }
    
    func test3posFractionalWidth() throws {
        let ls = LabelSpacer(tickPositions: [0,0.5,1], availWidth: 1, labelWidth: 0.5, minSpace: 0)
        XCTAssertEqual([true, true, true], ls.showLabel)
    }
    
    func test3posZeroWidthLabelMinSpace() throws {
        let ls = LabelSpacer(tickPositions: [0,0.5,1], availWidth: 1, labelWidth: 0, minSpace: 0.5)
        XCTAssertEqual([true, true, true], ls.showLabel)
    }

    func test3posNeedsMoreSpace() throws {
        let ls = LabelSpacer(tickPositions: [0,1,2], availWidth: 2, labelWidth: 1, minSpace: 0.1)
        XCTAssertEqual([true, false, true], ls.showLabel)
    }
    
    func test3posNarrowLabelSucceeds() throws {
        let ls = LabelSpacer(tickPositions: [0,1,2], availWidth: 2, labelWidth: 0.9, minSpace: 0.1)
        XCTAssertEqual([true, true, true], ls.showLabel)
    }

    func test3posCrowdedTrailing() throws {
        let ls = LabelSpacer(tickPositions: [0.1,1.1,2], availWidth: 2, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, true, false], ls.showLabel)
    }
    
    func test4pos() throws {
        let ls = LabelSpacer(tickPositions: [0,1,2,3], availWidth: 3, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, true, true, true], ls.showLabel)
    }
    
    func test4posRandom() throws {
        let ls = LabelSpacer(tickPositions: [0.1,0.9,1.9,2.9], availWidth: 3, labelWidth: 1, minSpace: 0)
        XCTAssertEqual([true, false, true, true], ls.showLabel)
    }
}
