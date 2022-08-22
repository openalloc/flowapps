//
//  MyDatePicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MyDatePicker: View {
    
    @Binding var date: Date
    var minimumDate: Date?
    var now: Date
    var onChange: (Date) -> Void
    
    public init(date: Binding<Date>, minimumDate: Date?, now: Date, onChange: @escaping (Date) -> Void) {
        _date = date
        self.minimumDate = minimumDate
        self.now = now
        self.onChange = onChange
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Group {
                if let _minimumDate = minimumDate, _minimumDate <= now {
                    DatePicker(selection: $date, in: _minimumDate ... now) {}
                } else {
                    DatePicker(selection: $date, in: PartialRangeThrough<Date>(now)) {}
                }
            }
            .datePickerStyle(CompactDatePickerStyle())
            .onChange(of: date, perform: onChange)
            
            Group {
                Button(action: { date = now }, label: {
                    Text("now")
                })
            }
            .buttonStyle(LinkButtonStyle())
        }
    }
}
