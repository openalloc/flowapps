//
//  CurrencyLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct CurrencyLabel: View {
    static let currencyBaseFullFormatter: NumberFormatter = {
        // no currency symbol in base formatter! Uses (parens) for negative numbers!
        let cbf = NumberFormatter()
        cbf.locale = Locale.current
        cbf.currencySymbol = ""
        cbf.numberStyle = .currencyAccounting
        return cbf
    }()

    // TODO: this should be configurable (decimals or none)
    static let currencyBaseFormatter: NumberFormatter = {
        // no currency symbol in base formatter! Uses (parens) for negative numbers!
        let cbf = NumberFormatter()
        cbf.locale = Locale.current
        cbf.currencySymbol = ""
        cbf.numberStyle = .currencyAccounting
        return cbf
    }()

    static let currencyBaseWholeFormatter: NumberFormatter = {
        // no currency symbol in base formatter! Uses (parens) for negative numbers!
        let cbf = NumberFormatter()
        cbf.locale = Locale.current
        cbf.currencySymbol = ""
        cbf.numberStyle = .currencyAccounting
        cbf.maximumFractionDigits = 0
        return cbf
    }()

    let value: Double
    var ifZero: String?
    var style: CurrencyStyle
    var leadingPlus: Bool
    
    public init(value: Double,
                ifZero: String? = nil,
                style: CurrencyStyle = .default_,
                leadingPlus: Bool = false) {
        self.value = value
        self.ifZero = ifZero
        self.style = style
        self.leadingPlus = leadingPlus
    }
    
    public var body: some View {
        if value == 0 && ifZero != nil {
            Text(ifZero!)
        } else {
            HStack {
                Text("\(currencyWholeFormatter.currencySymbol)")
                Spacer(minLength: 0)
                Text("\(leadingPlus && value > 0 ? "+" : "")\(formatted ?? "")")
            }
            .lineLimit(1)
        }
    }

    var formatted: String? {
        switch style {
        case .full:
            return CurrencyLabel.currencyBaseFullFormatter.string(from: value as NSNumber)
        case .default_:
            return CurrencyLabel.currencyBaseFormatter.string(from: value as NSNumber)
        case .whole:
            return CurrencyLabel.currencyBaseWholeFormatter.string(from: value as NSNumber)
        case .compact:
            return value.toGeneral(style: .compact, ifZero: ifZero)
        }
    }
}
