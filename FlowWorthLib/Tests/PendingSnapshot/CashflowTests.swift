//
//  CashflowTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class CashflowTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
    }
}
