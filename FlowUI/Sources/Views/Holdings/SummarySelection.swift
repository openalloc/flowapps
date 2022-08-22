//
//  SummarySelection.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData

import FlowBase

public extension SummarySelection {
    var description: String {
        switch self {
        case .presentValue:
            return "Present Value of Holdings"
        case .gainLossAmount:
            return "Gain/Loss of Holdings"
        case .gainLossPercent:
            return "Gain/Loss of Holdings"
        }
    }

    var symbol: String {
        switch self {
        case .presentValue:
            return "$"
        case .gainLossAmount:
            return "$"
        case .gainLossPercent:
            return "%"
        }
    }

    var fullDescription: String {
        "\(description) (\(symbol))"
    }

    var systemImage: (String, String) {
        switch self {
        case .presentValue:
            return ("shippingbox", "shippingbox.fill")
        case .gainLossAmount:
            return ("dollarsign.circle", "dollarsign.circle.fill")
        case .gainLossPercent:
            return ("plusminus.circle", "plusminus.circle.fill")
        }
    }

    func label(_ summarySelection: Binding<SummarySelection>) -> some View {
        let isSelected = summarySelection.wrappedValue == self
        return Label(fullDescription, systemImage: isSelected ? systemImage.1 : systemImage.0)
    }

    private static func myLabel(bsm: Binding<SummarySelection>, en: SummarySelection) -> some View {
        Image(systemName: bsm.wrappedValue == en ? en.systemImage.1 : en.systemImage.0)
    }

    static func picker(summarySelection: Binding<SummarySelection>) -> some View {
        Picker(selection: summarySelection, label: EmptyView()) {
            myLabel(bsm: summarySelection, en: SummarySelection.presentValue)
                .tag(SummarySelection.presentValue)
            myLabel(bsm: summarySelection, en: SummarySelection.gainLossAmount)
                .tag(SummarySelection.gainLossAmount)
            myLabel(bsm: summarySelection, en: SummarySelection.gainLossPercent)
                .tag(SummarySelection.gainLossPercent)
        }
        .help(summarySelection.wrappedValue.fullDescription)
    }
}
