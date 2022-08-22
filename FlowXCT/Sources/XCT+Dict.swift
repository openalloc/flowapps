//
//  XCT+Dict.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

public func XCTAssertEqual<K, T>(_ dict1: [K: T],
                                 _ dict2: [K: T],
                                 accuracy: T) where K: Hashable, T: FloatingPoint
{
    guard dict1.count == dict2.count else {
        XCTFail("dictionary sizes don't match")
        return
    }
    
    let keys1 = dict1.keys
    let keys2 = dict2.keys
    
    guard keys1 == keys2 else {
        XCTFail("dictionary keys don't match")
        return
    }
    
    keys1.forEach {
        let value1 = dict1[$0]!
        let value2 = dict2[$0]!
        XCTAssertEqual(value1, value2, accuracy: accuracy)
    }
}

public func XCTAssertEqual<T>(_ array1: [T],
                              _ array2: [T],
                              accuracy: T) where T: FloatingPoint
{
    guard array1.count == array2.count else {
        XCTFail("array sizes don't matc")
        return
    }
    
    (0..<array1.count).forEach {
        let value1 = array1[$0]
        let value2 = array2[$0]
        XCTAssertEqual(value1, value2, accuracy: accuracy)
    }
}

// dictionary of arrays of floats
public func XCTAssertEqual<K, T>(_ dict1: [K: [T]],
                                 _ dict2: [K: [T]],
                                 accuracy: T) where K: Hashable, T: FloatingPoint
{
    guard dict1.count == dict2.count else {
        XCTFail("dictionary sizes don't match")
        return
    }

    let keys1 = dict1.keys
    let keys2 = dict2.keys
    
    guard keys1 == keys2 else {
        XCTFail("dictionary keys don't match")
        return
    }

    keys1.forEach {
        let value1 = dict1[$0]!
        let value2 = dict2[$0]!
        XCTAssertEqual(value1, value2, accuracy: accuracy)
    }
}
