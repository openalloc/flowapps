//
//  AccountLabels.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowBase

public struct AccountTitleLabel: View {
    private let model: BaseModel
    private let ax: BaseContext
    private let accountKey: AccountKey?
    private let withID: Bool

    public init(model: BaseModel, ax: BaseContext, accountKey: AccountKey? = nil, withID: Bool) {
        self.model = model
        self.ax = ax
        self.accountKey = accountKey
        self.withID = withID
    }
    
    public var body: some View {
        Text(MAccount.getTitleID(accountKey, accountMap, withID: withID) ?? "")
    }
    
    private var accountMap: AccountMap {
        if ax.accountMap.count > 0 {
            return ax.accountMap
        }
        return model.makeAccountMap()
    }
}
