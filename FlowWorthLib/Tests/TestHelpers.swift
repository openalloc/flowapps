//
//  TestHelpers.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest

private var df = ISO8601DateFormatter()

func assertEqual(_ date1: Date?, _ date2: Date?, accuracy: Double) {
    guard let _date1 = date1 else { XCTFail("date1 is nil"); return }
    guard let _date2 = date2 else { XCTFail("date2 is nil"); return }
    XCTAssertEqual(_date1.timeIntervalSinceReferenceDate,
                   _date2.timeIntervalSinceReferenceDate,
                   accuracy: accuracy,
                   "\(df.string(from: _date1)) != \(df.string(from: _date2))")
}

