//
//  TimeZonePicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct TimeZonePicker: View {
    
    @Binding var timeZoneID: String
    
    public init(timeZoneID: Binding<String>) {
        _timeZoneID = timeZoneID
    }
    
    public var body: some View {
        HStack {
            Picker(selection: $timeZoneID, label: Text("Time Zone")) {
                Text("(use system default)")
                    .tag("")
                ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { tzID in
                    Text(tzID).tag(tzID)
                }
            }
            Group {
                Button(action: { timeZoneID = TimeZone.current.identifier }) {
                    Text("current")
                }
                Button(action: { timeZoneID = "" }) {
                    Text("clear")
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

//struct TimeZonePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeZonePicker()
//    }
//}
