//
//  InfoMessageStore+ImportResults.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation

import FlowBase

public extension InfoMessageStore {
    func displayImportResults(modelID: UUID, _ results: [BaseModel.ImportResult]) {
        guard results.count > 0 else { return }
        let importMessageStrs = BaseModel.ImportResult.getImportDetails(results)
        if importMessageStrs.count > 0 {
            self.add("Imported: \(importMessageStrs.joined(separator: "; "))", modelID: modelID, schemaName: nil)
        }
        let warnings = BaseModel.ImportResult.getImportWarnings(results)
        self.add(contentsOf: warnings, modelID: modelID)
    }
}


