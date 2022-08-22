//
//  Dict-Helpers.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Dictionary where Key: Comparable, Value: Numeric {
    
    // from current dict, subtract the keyed values of another dict
    //
    // ["a": 3, "b": 2].add(["a": 1, "c": 4]) => ["a": 4, "b": 2, "c": 4]
    //
    func add(_ other: [Key: Value]) -> [Key: Value] {
        let combinedKeys = Set(self.keys).union(other.keys)
        return combinedKeys.reduce(into: [:]) { map, key in
            let val = self[key, default: 0] + other[key, default: 0]
            if val != 0 {
                map[key] = val
            } else {
                map.removeValue(forKey: key)
            }
        }
    }
    
    // from current dict, subtract the keyed values of another dict
    //
    // ["a": 3, "b": 2].subtract(["a": 1, "c": 4]) => ["a": 2, "b": 2, "c": -4]
    //
    func subtract(_ other: [Key: Value]) -> [Key: Value] {
        let combinedKeys = Set(self.keys).union(other.keys)
        return combinedKeys.reduce(into: [:]) { map, key in
            let val = self[key, default: 0] - other[key, default: 0]
            if val != 0 {
                map[key] = val
            } else {
                map.removeValue(forKey: key)
            }
        }
    }

}
