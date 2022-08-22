//
//  BaseModel+Save.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension BaseModel {
    
    /// originalID == nil for adding new records
    /// returns true if saved; false if not
    public mutating func save<T: Identifiable>(_ element: T, to kp: AllocBaseKeyPath<T>, originalID: T.ID?) {
        _ = BaseModel.saveHelper(&self[keyPath: kp], element, originalID: originalID)
    }

    internal static func saveHelper<T: Identifiable>(_ modelArray: inout [T],
                                                     _ element: T,
                                                     originalID: T.ID?) -> Bool {
        let netID = originalID ?? element.id
        let idx = modelArray.firstIndex(where: { $0.id == netID })
        if originalID == nil {
            // it's new, so add if no conflicts
            guard idx == nil else { return false } // conflicting ID; not saved
            modelArray.append(element)
        } else {
            // it's existing, so replace if found
            guard idx != nil else { return false } // missing ID; not saved
            modelArray[idx!] = element
        }
        return true
    }
}

