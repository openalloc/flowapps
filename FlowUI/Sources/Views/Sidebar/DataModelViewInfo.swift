//
//  DataModelViewInfo.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import FlowBase

public struct DataModelViewInfo: Identifiable {
    public let id: String // menuID
    public let tableView: AnyView
    public let title: String
    public let count: Int
    
    public init(id: String, tableView: AnyView, title: String, count: Int) {
        self.id = id
        self.tableView = tableView
        self.title = title
        self.count = count
    }
}

public struct DataModelViewCommand: Identifiable {
    public let id: String // menuID
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

