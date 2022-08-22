//
//  MHolding+FlowTabular.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MHolding: FlowTabular {
    public var accountKey: MAccount.Key {
        MAccount.Key(accountID: accountID)
    }

    public var securityKey: MSecurity.Key {
        MSecurity.Key(securityID: securityID)
    }

    public func fkCreate(model: inout BaseModel) throws {
        if accountKey.isValid {
            // attempt to find existing record for account, if any specified, creating if needed
            _ = try model.importMinimal(MAccount(accountID: accountID), into: \.accounts)
        }
        if securityKey.isValid {
            // attempt to find existing record for security, if any specified, creating if needed
            _ = try model.importMinimal(MSecurity(securityID: securityID), into: \.securities)
        }
    }
}
