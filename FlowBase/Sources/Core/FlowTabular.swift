//
//  FlowTabular.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public protocol FlowTabular: AllocKeyed {
    
    typealias RawKeys = [String]

    // generate minimal record from a set of required keys
    //static func createMinimal(primaryKey: Key) throws -> Self

    // create any foreign keys as needed, so imports can happen in any order
    func fkCreate(model: inout BaseModel) throws
}
