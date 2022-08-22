//
//  DescribeUtils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import AllocData

public func describe(_ map: AccountAssetHoldingsSummaryMap, _ prefix: String) -> String {
    var buffer = [String]()

    for (accountID, hMap) in map.sorted(by: { $0.key < $1.key }) {
        buffer.append("\(accountID) => { \(describe(hMap)) }")
    }

    return "\(prefix) " + buffer.joined(separator: "; ")
}

public func describe(_ dict: AssetHoldingsSummaryMap) -> String {
    let ordered = dict.sorted(by: { $0.key < $1.key }) // key, ascending
    return ordered.map { "‘\($0.0)’: \($0.1)" }.joined(separator: ", ")
}

// Compound: 100232.10 (23%), 2323.13 (10%), ...
public func describe(total: Double, _ dict: [AssetKey: Double], _ prefix: String? = nil, orderByValue: Bool = true) -> String {
    let formatter: (Double) -> (String) = { "\((total * $0).currency0()) (\($0.percent1()))" }
    return describe(dict, prefix, orderByValue: orderByValue, formatter: formatter)
}

public func describe(_ dict: [AssetKey: Double], prefix: String? = nil, orderByValue: Bool = true, percent: Bool = false) -> String {
    let formatter: (Double) -> (String) = percent ? { $0.percent1() } : { $0.currency0() }
    return describe(dict, prefix, orderByValue: orderByValue, formatter: formatter)
}

private func describe(_ dict: [AssetKey: Double], _ prefix: String?, orderByValue: Bool, formatter: (Double) -> (String)) -> String {
    let ordered = orderByValue
        ? dict.sorted(by: { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }) // value, descending
        : dict.sorted(by: { $0.key < $1.key }) // key, ascending
    // let ordered2 = ordered.filter({ $0.1 != 0 })
    let suffix = ordered.map { "\($0.0): \(formatter($0.1))" }.joined(separator: ", ")
    let total = formatter(dict.values.reduce(0) { $0 + $1 })
    let suffix2 = "(\(ordered.count) @ \(total)) => \(suffix)"
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix2)"
    }
    return suffix2
}


public func describe(_ map: AssetHoldingsMap, _ securityMap: SecurityMap, _ prefix: String? = nil) -> String {
    var buffer = [String]()

    for (assetKey, holdings) in map.sorted(by: { $0.key < $1.key }) {
        buffer.append("\(assetKey) => [\n\t\(MHolding.describe(holdings, securityMap, separator: ",\n\t"))]")
    }

    let formattedValuesJoined = buffer.joined(separator: "\n")
    if let prefix_ = prefix {
        return "\(prefix_): \(formattedValuesJoined)"
    }
    return formattedValuesJoined
}

public func describe(_ map: [AssetKey: AssetKey], _ prefix: String? = nil) -> String {
    let suffix = map.sorted(by: { $0.key < $1.key }).map { "(\($0) -> \($1))" }.joined(separator: ", ")
    let suffix2 = "(\(map.count)) => \(suffix)"
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix2)"
    }
    return suffix2
}

public func describe(_ assetClasses: AssetKeySet, _ prefix: String? = nil) -> String {
    describe(Array(assetClasses), prefix)
}

public func describe(_ assetClasses: [AssetKey], _ prefix: String? = nil) -> String {
    let suffix = assetClasses.map { "\($0)" }.sorted(by: { $0 < $1 }).joined(separator: ", ")
    let suffix2 = "(\(assetClasses.count)) => \(suffix)"
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix2)"
    }
    return suffix2
}

public func describe(_ himap: AssetHoldingsSummaryMap, _ prefix: String? = nil) -> String {
    let suffix = himap.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: ", ")
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix)"
    }
    return suffix
}

public func describe(_ assetClassLimitMap: AssetAccountLimitMap, prefix: String? = nil) -> String {
    let suffix = assetClassLimitMap.sorted(by: { $0.key < $1.key })
        .map { "\($0.key): (\($0.value.map { "\($0.key): \($0.value.percent1())" }.joined(separator: ", ")))" }
        .joined(separator: "; ")
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix)"
    }
    return suffix
}

public func describe(accountUserVertLimitMap: AccountUserVertLimitMap, prefix: String? = nil) -> String {
    let suffix = accountUserVertLimitMap.sorted(by: { $0.key < $1.key })
        .map { "\($0.key): \(describe($0.value, percent: true))" }
        .joined(separator: "; ")
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix)"
    }
    return suffix
}

public func describe(accountUserAssetLimitMap: AccountUserAssetLimitMap, prefix: String? = nil) -> String {
    let suffix = accountUserAssetLimitMap.sorted(by: { $0.key < $1.key })
        .map { "\($0.key): \(describe($0.value, percent: true))" }
        .joined(separator: "; ")
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix)"
    }
    return suffix
}


public func describe(accountAssetValueMap: AccountAssetValueMap, prefix: String? = nil) -> String {
    let suffix = accountAssetValueMap.sorted(by: { $0.key < $1.key })
        .map { "\($0.key): \(describe($0.value, percent: true))" }
        .joined(separator: "; ")
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix)"
    }
    return suffix
}


public func describe(_ accounts: [MAccount], _ prefix: String? = nil) -> String {
    // : \($0.holdings.count) holdings @ \($0.holdingsPresentValue.currency0())
    let suffix = accounts.map { "\($0.title ?? "") (\($0.accountID))" }.joined(separator: "; ")
    // let total = accounts.reduce(0) { $0 + $1.holdingsPresentValue }.currency0()
    let suffix2 = suffix // (\(accounts.count) @ \(total)) => \(suffix)"
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix2)"
    }
    return suffix2
}

private func describe(_ dict: [String: Double], _ prefix: String?, orderByValue: Bool = true, formatter: (Double) -> (String)) -> String {
    let ordered = orderByValue
        ? dict.sorted(by: { $0.value > $1.value || ($0.value == $1.value && $0.key < $1.key) }) // value, descending
        : dict.sorted(by: { $0.key < $1.key }) // key, ascending
    // let ordered2 = ordered.filter({ $0.1 != 0 })
    let suffix = ordered.map { "\($0.0): \(formatter($0.1))" }.joined(separator: ", ")
    let total = formatter(dict.values.reduce(0) { $0 + $1 })
    let suffix2 = "(\(ordered.count) @ \(total)) => \(suffix)"
    if let prefix_ = prefix {
        return "\(prefix_) \(suffix2)"
    }
    return suffix2
}
