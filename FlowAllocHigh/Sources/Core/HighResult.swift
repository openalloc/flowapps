//
//  HighResult.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase


public struct HighResult: Hashable, Identifiable {
    public var id: Int { hashValue }
    public let accountKeys: [AccountKey]
    public let assetKeys: [AssetKey]
    public let flowMode: Double
    public let accountAllocMap: AccountAssetValueMap
    public let accountRebalanceMap: AccountRebalanceMap
    public let accountReducerMap: AccountReducerMap
    public let transactionCount: Int
    public let netTaxGains: Double
    public let absTaxGains: Double
    public let saleVolume: Double
    public let washAmount: Double

    public init(accountKeys: [AccountKey] = [],
                assetKeys: [AssetKey] = [],
                flowMode: Double = 0,
                accountAllocMap: AccountAssetValueMap = [:],
                accountRebalanceMap: AccountRebalanceMap = [:],
                accountReducerMap: AccountReducerMap = [:],
                transactionCount: Int = 0,
                netTaxGains: Double = 0,
                absTaxGains: Double = 0,
                saleVolume: Double = 0,
                washAmount: Double = 0)
    {
        self.accountKeys = accountKeys
        self.assetKeys = assetKeys
        self.flowMode = flowMode
        self.accountAllocMap = accountAllocMap
        self.accountRebalanceMap = accountRebalanceMap
        self.accountReducerMap = accountReducerMap
        self.transactionCount = transactionCount
        self.netTaxGains = netTaxGains
        self.absTaxGains = absTaxGains
        self.saleVolume = saleVolume
        self.washAmount = washAmount
    }

    // deliberately no accountkeys/assetkeys, as we want to ignore order when finding dupes
    // also excluding flowModeInt
    public static func == (lhs: HighResult, rhs: HighResult) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    /**
     Note: hash order IS SIGNIFICANT
     
     var hasherB = Hasher()
     hasherB.combine(23)
     hasherB.combine("Hello")
     let hashValueB = hasherB.finalize()

     var hasherC = Hasher()
     hasherC.combine("Hello")
     hasherC.combine(23)
     let hashValueC = hasherC.finalize()  // different than B
     */
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transactionCount)
        hasher.combine(taxableGainsDollars)
        hasher.combine(absTaxableGainsDollars)
        hasher.combine(volumeDollars)
        hasher.combine(washAmountDollars)
    }
    
    public func getBaseParams(isStrict: Bool, fixedAccountKeys: [AccountKey]) -> BaseParams {
        BaseParams(accountKeys: accountKeys,
                   assetKeys: assetKeys,
                   flowMode: flowMode,
                   isStrict: isStrict,
                   fixedAccountKeys: fixedAccountKeys)
    }

    public var flowModeInt: Int {
        Int(flowMode * 10000)
    }

    public var taxableGainsDollars: Int {
        Int(netTaxGains)
    }

    public var absTaxableGainsDollars: Int {
        Int(absTaxGains)
    }

    public var volumeDollars: Int {
        Int(saleVolume)
    }

    public var washAmountDollars: Int {
        Int(washAmount)
    }
}
