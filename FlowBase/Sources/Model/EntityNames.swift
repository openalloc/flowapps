//
//  EntityNames.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public protocol EntityNamed {
    typealias Tuple = (singular: String, plural: String)
    static var entityName: Tuple { get }
}

extension MAccount: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "account", plural: "accounts")
    }
}

extension MAllocation: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "strategy allocation", plural: "strategy allocations")
    }
}

extension MAsset: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "asset", plural: "assets")
    }
}

extension MCap: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "account cap", plural: "account caps")
    }
}

extension MTransaction: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "transaction", plural: "transactions")
    }
}

extension MHolding: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "account holding", plural: "account holdings")
    }
}

extension MSecurity: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "security", plural: "securities")
    }
}

extension MStrategy: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "strategy", plural: "strategies")
    }
}

extension MTracker: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "index tracker", plural: "index trackers")
    }
}

extension MValuationSnapshot: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "valuation snapshot", plural: "valuation snapshots")
    }
}

extension MValuationPosition: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "valuation position", plural: "valuation positions")
    }
}

extension MValuationCashflow: EntityNamed {
    public static var entityName: Tuple {
        Tuple(singular: "valuation cash flow", plural: "valuation cash flow")
    }
}
