//
//  BaseModel+ImportResult.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter
import FlowBase

public extension BaseModel.ImportResult {
    
    static func getImportDetails(_ results: [BaseModel.ImportResult]) -> [String] {
        
        let resultsByFileName = Dictionary(grouping: results, by: { String($0.url?.lastPathComponent ?? "unknown") })
        
        return resultsByFileName.reduce(into: []) { array, entry in
            let (filename, results) = entry
            let schemaNames = results.compactMap { $0.allocSchema?.camelCasePluralName }
            guard schemaNames.count > 0 else { return }
            array.append("\(filename) (\(schemaNames.joined(separator: ", ")))")
        }
    }
    
    static func getImportWarnings(_ results: [BaseModel.ImportResult]) -> [InfoMessageStore.Message] {
        results.reduce(into: []) { array, result in
            guard result.hasIssue,
                  let prefix = result.warningDescription else { return }
            let schemaName = result.allocSchema?.camelCasePluralName
            array.append(InfoMessageStore.Message(val: prefix, schemaName: schemaName, rejectedRows: result.rejectedRows))
        }
    }
}
