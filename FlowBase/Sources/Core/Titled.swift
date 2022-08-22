//
//  Titled.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter

public protocol Titled {
    var titleID: String { get }
    var title: String? { get }
}

extension Titled {
    var normTitle: String {
        guard let _title = title else { return "" }
        return _title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Enforce a non-blank (and non-nil) title
    public var isTitleValid: Bool {
        normTitle.count > 0
    }
}

extension BaseModel {
    
    /// return true if a non-blank normalized title is present in the model
    func hasConflictingTitle<T>(_ element: T, keyPath: AllocBaseKeyPath<T>) -> Bool
    where T: AllocKeyed & Titled {
        let _normTitle = element.normTitle
        guard _normTitle.count > 0 else { return false } // conflicting blanks are fine
        let records = self[keyPath: keyPath]
        let _primaryKey = element.primaryKey
        return records.contains(where: { $0.primaryKey != _primaryKey && $0.normTitle == _normTitle })
    }
}
