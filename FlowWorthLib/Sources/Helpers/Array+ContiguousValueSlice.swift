//
//  Array-ContiguousValueSlice.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Array where Element: Equatable {
    
    /// NOTE array values should be ordered
    func contiguousValueSlice(startValue: Element, endValue: Element) -> ArraySlice<Element>? {
       
        guard let startIndex = self.firstIndex(where: { $0 == startValue })
        else { return nil }
        
        let remainder = self.suffix(from: startIndex)
        
        guard let endIndex = remainder.firstIndex(where: { $0 == endValue })
        else { return nil }
       
        return self[startIndex ... endIndex]
    }
}

