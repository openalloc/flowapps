//
//  ResultSort.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct ResultSort: Hashable, Codable {
    public enum Attribute: String, Codable, CaseIterable {
        case netTaxGains
        case absTaxGains
        case saleVolume
        case transactionCount
        case flowMode
        case wash
    }

    public enum Direction: Int, Codable, CaseIterable {
        case ascending
        case descending
    }

    public var attribute: Attribute
    public var direction: Direction

    public init(_ attribute: Attribute, _ direction: Direction = .ascending) {
        self.attribute = attribute
        self.direction = direction
    }

    public var otherDirection: Direction {
        direction == .ascending ? .descending : .ascending
    }

    public static func getTitle(_ attribute_: Attribute) -> String {
        switch attribute_ {
        case .netTaxGains:
            return "Net Gains"
        case .absTaxGains:
            return "Abs Gains"
        case .saleVolume:
            return "Sale Volume"
        case .transactionCount:
            return "Txn Count"
        case .flowMode:
            return "Flow Value"
        case .wash:
            return "Wash Sale"
        }
    }

    public static func getDirection(_ direction_: Direction, compact: Bool = false) -> String {
        switch direction_ {
        case .ascending:
            return compact ? "asc" : "Ascending Order"
        case .descending:
            return compact ? "desc" : "Descending Order"
        }
    }
}
