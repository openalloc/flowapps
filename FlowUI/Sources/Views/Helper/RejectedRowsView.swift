//
//  RejectedRowsView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData

struct RejectedRowsView: View {
    
    public let accent: Color
    @Binding var schemaName: String
    @Binding var rejectedRows: [AllocRowed.DecodedRow]
    var onDismiss: () -> ()
    
    var body: some View {
        VStack {
            HStack {
                Text("Rejected Rows for ‘\(schemaName)’ Import")
                    .font(.title)
                Spacer()
                DismissButton(onDismiss: onDismiss)
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<headerKeys.count, id: \.self) { n in
                    Text(headerKeys[n])
                }
            }
            .background(accent.opacity(0.1))
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(0..<rejectedRows.count, id: \.self) { n in
                        LazyVGrid(columns: columns, spacing: 10) {
                            rowElements(rejectedRows[n])
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private func rowElements(_ row: AllocRowed.DecodedRow) -> some View {
        ForEach(headerKeys, id: \.self) { key in
            VStack {
                if let str = row[key] {
                    Text(String(describing: str))
                } else {
                    Text("-")
                }
            }
        }
    }
    
    private var columns: [GridItem] {
        headerKeys.map { _ in
            GridItem(.fixed(100))
        }
    }
    
    private var headerKeys: [String] {
        var keys = Set<String>()
        for row in rejectedRows {
            row.keys.forEach {
                guard $0.count > 0,
                      !keys.contains($0),
                      let val = row[$0]?.description.trimmingCharacters(in: .whitespaces),
                      val.count > 0,
                      val != "--"
                else { return }
                keys.insert($0)
            }
        }
        return keys.sorted()
    }
}
