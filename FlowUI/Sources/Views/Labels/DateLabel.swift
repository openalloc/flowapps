//
//  DateLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct DateLabel: View {
    static let df: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    static let dft: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()

    private var date: Date?
    private var withTime: Bool
    private var defaultValue: String

    public init(_ date: Date?, withTime: Bool = false, defaultValue: String = "") {
        self.date = date
        self.withTime = withTime
        self.defaultValue = defaultValue
    }
    
    public var body: some View {
        Text(formattedValue)
    }
    
    private var formattedValue: String {
        if let _d = date {
            return f.string(from: _d)
        } else {
            return defaultValue
        }
    }
    
    private var f: DateFormatter {
        withTime ? DateLabel.dft : DateLabel.df
    }
}

