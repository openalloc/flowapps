//
//  MAccount+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAccount.Key: CustomStringConvertible {
    public var description: String {
        "AccountID: '\(accountNormID)'"
    }
}

extension MAccount: Titled {
    public var titleID: String {
        guard let title_ = title else { return accountID }
        return title_ == accountID ? title_ : "\(title_) (\(accountID))"
    }
}

public extension MAccount {
    static func getTitleID(_ accountKey: AccountKey?, _ accountMap: AccountMap, withID: Bool) -> String? {
        guard let account = getAccount(accountKey, accountMap)
        else { return nil }
        return withID ? account.titleID : account.title
    }

    private static func getAccount(_ accountKey: AccountKey?, _ accountMap: AccountMap) -> MAccount? {
        guard let accountKey_ = accountKey,
              let account = accountMap[accountKey_] else { return nil }
        return account
    }
}

