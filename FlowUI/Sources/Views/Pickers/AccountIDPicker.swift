//
//  AccountPicker.swift
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

public struct AccountIDPicker<Label>: View where Label: View {
    var accounts: [MAccount]
    @Binding var accountID: AccountID
    var label: () -> Label

    public init(accounts: [MAccount],
                accountID: Binding<AccountID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.accounts = accounts
        _accountID = accountID
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $accountID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { account in
                Text(account.titleID)
                    .tag(account.accountID)
            }
        }
    }

    private var ordered: [MAccount] {
        accounts.sorted()
    }
}
