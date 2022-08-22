//
//  DetailPayload.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct DetailPayload {
    public init(modelID: UUID, selectedIndex: Int? = nil) {
        self.modelID = modelID
        self.selectedIndex = selectedIndex
    }
    
    public var modelID: UUID
    public var selectedIndex: Int?
}

