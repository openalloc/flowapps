//
//  Export-utils.swift
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

public func exportData<T: AllocAttributable>(_ records: [T],
                          format: AllocFormat) throws -> Data
    where T: AllocBase & Encodable
{
    guard let delimiter = format.delimiter
    else { throw FlowBaseError.encodingError("Format \(format.rawValue) not supported for export.") }
    let encoder = DelimitedEncoder(delimiter: String(delimiter))
    let headers = AllocAttribute.getHeaders(T.attributes)
    _ = try encoder.encode(headers: headers)
    return try encoder.encode(rows: records)
}
