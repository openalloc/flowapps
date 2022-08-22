//
//  SharesLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct SharesLabel: View {
    static let sharesRegularFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale.current
        nf.numberStyle = .decimal
        nf.isLenient = true
        nf.usesSignificantDigits = true
        nf.minimumSignificantDigits = 1
        nf.maximumSignificantDigits = 5
        return nf
    }()

    let value: Double?
    let ifZero: String?
    let style: SharesStyle
    let epsilon: Double
    
    public init(value: Double?, ifZero: String? = nil, style: SharesStyle = .default_, epsilon: Double = 0.000001) {
        self.value = value
        self.ifZero = ifZero
        self.style = style
        self.epsilon = epsilon
    }

    public var body: some View {
        HStack {
            Spacer()
            Text(formatted ?? "")
        }
        .lineLimit(1)
    }
    
    private var formatted: String? {
        guard let value_ = value else { return nil }
        switch style {
        case .default_:
            if value?.isEqual(to: 0, accuracy: epsilon) ?? true {
                return "0" // avoid 0.0000000001343
            }
            return SharesLabel.sharesRegularFormatter.string(from: value_ as NSNumber)
        case .compact:
            return value_.toCompact(nf1: SharesLabel.sharesRegularFormatter, ifZero: ifZero)
        }
    }
}
