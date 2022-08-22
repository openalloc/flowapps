//
//  SidebarAccountsView.swift
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
import FlowViz

struct SidebarAccountsView<AS>: View where AS: View {
    let accountSummary: (MAccount) -> AS
    var assetColorMap: AssetColorMap
    var fetchAssetValues: FetchAssetValues
    var accounts: [MAccount]
    @Binding var activeSidebarMenuKey: String?

    var body: some View {
        ForEach(accounts, id: \.self) { account in
            NavigationLink(
                destination: accountSummary(account),
                tag: account.primaryKey.accountNormID,
                selection: $activeSidebarMenuKey
            ) {
                row(account)
            }
        }
    }

    private func row(_ account: MAccount) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(account.title ?? "")
                .mpadding()
            VizBarView(getTargetAlloc(account))
                .shadow(radius: 1, x: 2, y: 2)
        }
    }

    // MARK: - Helpers

    private func getTargetAlloc(_ account: MAccount) -> [VizSlice] {
        let av = fetchAssetValues(account.primaryKey)
        let ta = av.map { VizSlice($0.value, assetColorMap[$0.assetKey]?.1 ?? Color.gray) }
        guard ta.count > 0 else { return [VizSlice(1.0, Color.gray)] }
        return ta
    }
}
