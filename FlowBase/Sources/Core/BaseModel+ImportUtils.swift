//
//  BaseModel+ImportUtils.swift
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

extension BaseModel {
    
    /// return true if the model contains the specified key (for the table)
    func containsKey<T>(_ key: T.Key, keyPath: AllocBaseKeyPath<T>) -> Bool
    where T: AllocKeyed {
        getIndex(primaryKey: key, from: keyPath) != nil
    }
    
    // High-level row importer. Will create foreign key records and validate too.
    mutating public func importRow<T>(_ other: AllocRowed.DecodedRow, into keyPath: AllocBaseKeyPath<T>) throws -> Int
        where T: AllocRowed & AllocBase & FlowTabular & BaseValidator
    {
        let (record, index) = try importAdditive(from: other, into: keyPath)
        return try importReplaceAppend(from: record, into: keyPath, index: index)
    }

    // Following validation, REPLACE existing record at index, or APPEND new record.
    // Does NOT create minimal records for foreign keys.
    // Does NOT validate (call try importValidate(record, model) separately)
    // Used directly in Detail.
    mutating public func importRecord<T>(_ record: T, into keyPath: AllocBaseKeyPath<T>) throws -> Int
        where T: AllocBase & FlowTabular & BaseValidator
    {
        let index = getIndex(primaryKey: record.primaryKey, from: keyPath)
        return try importReplaceAppend(from: record, into: keyPath, index: index)
    }

    // Used during bulk import to establish foreign key records, allowing imports to be done in any order.
    // NOTE: assumes existing record with key does NOT yet exist
    mutating public func importMinimal<T>(_ element: T, into keyPath: AllocBaseKeyPath<T>) throws -> Int
        where T: AllocBase & FlowTabular & AllocKeyed
    {
        if let n = getIndex(primaryKey: element.primaryKey, from: keyPath) { return n }
        return importAppend(element, into: keyPath)
    }

    // MARK: - Internal Support

    func getIndex<T: AllocKeyed>(primaryKey: T.Key, from keyPath: AllocBaseKeyPath<T>) -> Int?
        where T: AllocBase
    {
        let records = self[keyPath: keyPath]
        return records.firstIndex(where: { $0.primaryKey == primaryKey })
    }

    mutating func importReplaceAppend<T>(from record: T, into keyPath: AllocBaseKeyPath<T>, index: Int?) throws -> Int
        where T: Equatable & FlowTabular & BaseValidator
    {
        try record.fkCreate(model: &self)
        try importValidate(record)

        if let index_ = index {
            return importReplace(record, into: keyPath, index: index_)
        } else {
            return importAppend(record, into: keyPath)
        }
    }

    // Following validation, REPLACE existing record at index, or APPEND new record.
    mutating func importAppend<T>(_ record: T, into keyPath: AllocBaseKeyPath<T>) -> Int
        where T: AllocBase
    {
        self[keyPath: keyPath].append(record)
        return self[keyPath: keyPath].count - 1
    }

    mutating func importReplace<T>(_ record: T, into keyPath: AllocBaseKeyPath<T>, index: Int) -> Int
        where T: Equatable
    {
        // no need to mutate if nothing has changed
        if self[keyPath: keyPath][index] != record {
            // update existing in place
            // model.securities[index].update(from: nu)  // caused problem with mutating dictionary elements in table views
            self[keyPath: keyPath].remove(at: index)
            self[keyPath: keyPath].insert(record, at: index)
        }
        return index
    }

    mutating func importAdditive<T: AllocRowed>(from other: AllocRowed.DecodedRow, into keyPath: AllocBaseKeyPath<T>) throws -> (T, Int?)
        where T: AllocBase
    {
        // attempt to find existing security with same securityID (nil if not found)
        let otherPrimaryKey = try T.getPrimaryKey(other)
        let index = getIndex(primaryKey: otherPrimaryKey, from: keyPath)

        let record: T = try {
            if let index_ = index {
                // existing record
                var nu = self[keyPath: keyPath][index_]
                try nu.update(from: other)
                return nu
            } else {
                // new record
                return try T(from: other)
            }
        }()

        return (record, index)
    }

    mutating func importValidate<T>(_ record: T) throws
        where T: BaseValidator
    {
        try record.validate(epsilon: 0.0001)
        
        // NOTE import can be for new or existing records
        try record.validate(against: self, isNew: false)
    }
}
