//
//  Sequence+Sorted.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/*
 Via Leo Dabus: https://stackoverflow.com/posts/31528848/revisions
 
 Usage:
 
 let sortedFruitsAscending = fruitsDict.sorted(\.value)
 print(sortedFruitsAscending)

 let sortedFruitsDescending = fruitsDict.sorted(\.value, by: >)
 print(sortedFruitsDescending)
 */
extension Sequence {
    public func sorted<T: Comparable>(_ predicate: (Element) -> T, by areInIncreasingOrder: ((T,T)-> Bool) = (<)) -> [Element] {
        sorted(by: { areInIncreasingOrder(predicate($0), predicate($1)) })
    }
}
