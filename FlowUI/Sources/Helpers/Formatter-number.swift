//
//  Formatter-number.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import Compactor

let currencyFullFormatter: NumberFormatter = {
    let cff = NumberFormatter()
    cff.locale = Locale.current
    //        crf.currencyCode = surgeModel.settings.currencyCode
    cff.numberStyle = .currency
    cff.isLenient = true
    cff.minimumFractionDigits = 2
    cff.maximumFractionDigits = 2
    return cff
}()

let currencyRegularFormatter: NumberFormatter = {
    let crf = NumberFormatter()
    crf.locale = Locale.current
    //        crf.currencyCode = surgeModel.settings.currencyCode
    crf.numberStyle = .currency
    crf.isLenient = true
    return crf
}()

let currencyWholeFormatter: NumberFormatter = {
    let cwf = NumberFormatter()
    cwf.locale = Locale.current
    cwf.numberStyle = .currency
    cwf.isLenient = true
    cwf.minimumFractionDigits = 0
    cwf.maximumFractionDigits = 0
    return cwf
}()

let sharesRegularFormatter: NumberFormatter = {
    let srf = NumberFormatter()
    srf.locale = Locale.current
    srf.numberStyle = .decimal
    srf.isLenient = true
    srf.usesSignificantDigits = true
    srf.minimumSignificantDigits = 1
    srf.maximumSignificantDigits = 8 // storedValue(.sharesSignificantDigits, HighDefaults.defaultSharesSignificantDigits)
    return srf
}()

let percentFormatter1: NumberFormatter = {
    let pf = NumberFormatter()
    pf.locale = Locale.current
    pf.numberStyle = .percent
    pf.isLenient = true
    pf.minimumFractionDigits = 1
    pf.maximumFractionDigits = 1
    return pf
}()

let percentFormatter2: NumberFormatter = {
    let pf = NumberFormatter()
    pf.locale = Locale.current
    pf.numberStyle = .percent
    pf.isLenient = true
    pf.minimumFractionDigits = 2
    pf.maximumFractionDigits = 2
    return pf
}()

let generalFormatter: NumberFormatter = {
    let gf = NumberFormatter()
    gf.locale = Locale.current
    gf.numberStyle = .decimal
    gf.isLenient = true
    gf.minimumFractionDigits = 1
    gf.maximumFractionDigits = 1
    return gf
}()

let generalWholeFormatter: NumberFormatter = {
    let gwf = NumberFormatter()
    gwf.locale = Locale.current
    gwf.numberStyle = .decimal
    gwf.isLenient = true
    gwf.minimumFractionDigits = 0
    gwf.maximumFractionDigits = 0
    return gwf
}()

public enum CurrencyStyle {
    case full // with standard decimal points for locale
    case default_ // whatever the user configured
    case whole // whatever the user configured, dropping decimal
    case compact // using the $45.3K style
}

public enum PercentStyle {
    case default_ // whatever the user configured
    case whole // dropping decimal
}

public enum SharesStyle {
    case default_
    case compact
}

public enum GeneralStyle {
    case default_ // whatever the user configured
    case whole // whatever the user configured, dropping decimal
    case compact // using the 45.3K style
}

public extension Double {
    // TODO: use formatter.positivePrefix for leadingPlus
    func toCurrency(style: CurrencyStyle = .default_, leadingPlus: Bool = false, ifZero: String? = nil) -> String {
        if ifZero != nil, isEqual(to: 0, accuracy: 0.01) { return ifZero! }
        let suffix: String = {
            switch style {
            case .full:
                return currencyFullFormatter.string(from: self as NSNumber) ?? ""
            case .default_:
                return currencyRegularFormatter.string(from: self as NSNumber) ?? ""
            case .whole:
                return currencyWholeFormatter.string(from: self as NSNumber) ?? ""
            case .compact:
                //TODO need better implementation that avoids creating new formatter
                let cc = CurrencyCompactor(ifZero: ifZero)
                cc.currencyCode = currencyRegularFormatter.currencyCode
                cc.currencyDecimalSeparator = currencyRegularFormatter.currencyDecimalSeparator
                return cc.string(from: self as NSNumber) ?? ""
            }
        }()
        if leadingPlus, self > 0 { return "+\(suffix)" }
        return suffix
    }

    func toShares() -> String {
        sharesRegularFormatter.string(from: NSNumber(value: self)) ?? ""
    }

    func toPercent1(leadingPlus: Bool = false, ifZero: String? = nil) -> String {
        toPercent(leadingPlus: leadingPlus, ifZero: ifZero, epsilon: 0.001, formatter: percentFormatter1)
    }
        
    func toPercent2(leadingPlus: Bool = false, ifZero: String? = nil) -> String {
        toPercent(leadingPlus: leadingPlus, ifZero: ifZero, epsilon: 0.0001, formatter: percentFormatter2)
    }
    
    private func toPercent(leadingPlus: Bool, ifZero: String?, epsilon: Double, formatter: NumberFormatter) -> String {
        if ifZero != nil, isEqual(to: 0, accuracy: epsilon) { return ifZero! }
        let suffix = formatter.string(from: self as NSNumber) ?? ""
        if leadingPlus, self > 0 { return "+\(suffix)" }
        return suffix
    }

    private static let compactFormatter1 = NumberCompactor(ifZero: nil)
    private static let compactFormatter2 = NumberCompactor(ifZero: "")
    
    func toGeneral(style: GeneralStyle = .default_, ifZero: String? = nil) -> String {
        if ifZero != nil, isEqual(to: 0, accuracy: 0.01) { return ifZero! }
        switch style {
        case .default_:
            return generalFormatter.string(from: self as NSNumber) ?? ""
        case .whole:
            return generalWholeFormatter.string(from: self as NSNumber) ?? ""
        case .compact:
            let nc = ifZero == nil ? Double.compactFormatter1 : Double.compactFormatter2
            return nc.string(from: self as NSNumber) ?? ""
        }
    }

    // used in shares formatting
    func toCompact(nf1: NumberFormatter?,
                   ifZero: String? = nil) -> String?
    {
        //TODO need better implementation
        let nc = NumberCompactor(ifZero: ifZero)
        nc.currencyCode = nf1?.currencyCode
        nc.currencyDecimalSeparator = nf1?.decimalSeparator
        nc.decimalSeparator = nf1?.decimalSeparator
        return nc.string(from: self as NSNumber)
    }
}
