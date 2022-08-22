//
//  MValuationCashflow+FlowTabular.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationCashflow: FlowTabular {
    public var accountKey: MAccount.Key {
        MAccount.Key(accountID: accountID)
    }

    public var assetKey: MAsset.Key {
        MAsset.Key(assetID: assetID)
    }

    public func fkCreate(model: inout BaseModel) throws {
        if accountKey.isValid {
            // attempt to find existing record for account, if any specified, creating if needed
            _ = try model.importMinimal(MAccount(accountID: accountID), into: \.accounts)
        }
        if assetKey.isValid {
            // attempt to find existing record for asset, if any specified, creating if needed
            _ = try model.importMinimal(MAsset(assetID: assetID), into: \.assets)
        }
    }
}
