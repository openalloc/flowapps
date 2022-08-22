//
//  TimeOfDayPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct TimeOfDayPicker: View {
    
    public enum Vals: String, CaseIterable {
        case useDefault = ""
        case z00_00 = "00:00"
        case z01_00 = "01:00"
        case z02_00 = "02:00"
        case z03_00 = "03:00"
        case z04_00 = "04:00"
        case z05_00 = "05:00"
        case z06_00 = "06:00"
        case z07_00 = "07:00"
        case z08_00 = "08:00"
        case z09_00 = "09:00"
        case z10_00 = "10:00"
        case z11_00 = "11:00"
        case z12_00 = "12:00"
        case z13_00 = "13:00"
        case z14_00 = "14:00"
        case z15_00 = "15:00"
        case z16_00 = "16:00"
        case z17_00 = "17:00"
        case z18_00 = "18:00"
        case z19_00 = "19:00"
        case z20_00 = "20:00"
        case z21_00 = "21:00"
        case z22_00 = "22:00"
        case z23_00 = "23:00"
        
        var description: String {
            switch self {
            case .useDefault:
                return "(use default)"
            case .z00_00:
                return "\(rawValue) (midnight)"
            case .z12_00:
                return "\(rawValue) (noon)"
            default:
                return rawValue
            }
        }
    }
    
    var title: String
    @Binding var timeOfDay: Vals
    
    public init(title: String? = nil, timeOfDay: Binding<Vals>) {
        self.title = title ?? "Time of Day"
        _timeOfDay = timeOfDay
    }
    
    public var body: some View {
        HStack {
            Picker(selection: $timeOfDay, label: Text(title)) {
                ForEach(TimeOfDayPicker.Vals.allCases, id: \.self) { tod in
                    Text(tod.description).tag(tod)
                }
            }
            Group {
                Button(action: { timeOfDay = .useDefault }) {
                    Text("clear")
                }
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
}

