//
//  MAsset+FlowTabular.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MAsset: FlowTabular {
    public var parentAssetKey: MAsset.Key {
        MAsset.Key(assetID: parentAssetID)
    }

    public func fkCreate(model: inout BaseModel) throws {
        if parentAssetKey.isValid {
            // attempt to find existing record for parent asset, if any specified, creating if needed
            _ = try model.importMinimal(MAsset(assetID: parentAssetID), into: \.assets)
        }
    }
}
