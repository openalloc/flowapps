//
//  MAsset+StandardID.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter

public extension MAsset.StandardID {
        
    static var standardAssets: [MAsset] {
        MAsset.StandardID.allCases.map {
            MAsset(assetID: $0.rawValue,
                   title: $0.assetIdDescription,
                   colorCode: $0.defaultColorCode,
                   parentAssetID: $0.defaultParentID?.rawValue)
        }
    }

    // TODO currently US-centric
    var assetIdDescription: String {
        switch self {
        case .bond:
            return "Aggregate Bonds"
        case .cash:
            return "Cash & Cash Equivalent"
        case .cmdty:
            return "Commodities"
        case .corpbond:
            return "Corporate Bonds"
        case .em:
            return "Emerging Market Equities"
        case .embond:
            return "Emerging Market Bonds"
        case .europe:
            return "Europe Equities"
        case .globre:
            return "Global Real Estate"
        case .gold:
            return "Gold"
        case .hybond:
            return "High Yield Bonds"
        case .intl:
            return "Foreign Equities"
        case .intlbond:
            return "Foreign Aggregate Bonds"
        case .intlgov:
            return "Foreign Government Bonds"
        case .intlre:
            return "Foreign Real Estate"
        case .intlsc:
            return "Foreign Small Cap Equities"
        case .intlval:
            return "Foreign Value"
        case .itgov:
            return "Int-Term Treasuries"
        case .japan:
            return "Japan Equities"
        case .lc:
            return "Large Cap Blend"
        case .lcgrow:
            return "Large Cap Growth"
        case .lcval:
            return "Large Cap Value"
        case .ltgov:
            return "Long-Term Treasuries"
        case .mc:
            return "Mid Cap Blend"
        case .mcgrow:
            return "Mid Cap Growth"
        case .mcval:
            return "Mid Cap Value"
        case .momentum:
            return "Momentum"
        case .pacific:
            return "Pacific Equities"
        case .re:
            return "Real Estate"
        case .remort:
            return "Mortgage REITs"
        case .sc:
            return "Small Cap Blend"
        case .scgrow:
            return "Small Cap Growth"
        case .scval:
            return "Small Cap Value"
        case .stgov:
            return "Short-Term Treasuries"
        case .tech:
            return "Technology"
        case .tips:
            return "TIPS"
        case .total:
            return "Total Market"
        }
    }
    
    var defaultParentID: MAsset.StandardID? {
        switch self {
        case .corpbond:
            return .bond
        case .em:
            return .intl
        case .embond:
            return .intlbond
        case .europe:
            return .intl
        case .intlgov:
            return .intlbond
        case .intlre:
            return .intl
        case .intlsc:
            return .intl
        case .intlval:
            return .intl
        case .itgov:
            return .bond
        case .japan:
            return .intl
        case .lc:
            return .total
        case .lcgrow:
            return .lc
        case .lcval:
            return .lc
        case .mc:
            return .lc
        case .mcgrow:
            return .mc
        case .mcval:
            return .mc
        case .momentum:
            return .lc
        case .pacific:
            return .intl
        case .re:
            return .lc
        case .remort:
            return .re
        case .sc:
            return .mc
        case .scgrow:
            return .sc
        case .scval:
            return .sc
        case .stgov:
            return .cash
        case .tech:
            return .lc
        case .tips:
            return .bond
        default:
            return nil
        }
    }
    
    var defaultColorCode: Int {
        switch self {
        case .bond:
            return 125
        case .cash:
            return 120
        case .cmdty:
            return 113
        case .corpbond:
            return 128
        case .em:
            return 164
        case .embond:
            return 131
        case .europe:
            return 161
        case .globre:
            return 103
        case .gold:
            return 117
        case .hybond:
            return 129
        case .intl:
            return 157
        case .intlbond:
            return 126
        case .intlgov:
            return 127
        case .intlre:
            return 104
        case .intlsc:
            return 160
        case .intlval:
            return 158
        case .itgov:
            return 124
        case .japan:
            return 163
        case .lc:
            return 137
        case .lcgrow:
            return 139
        case .lcval:
            return 138
        case .ltgov:
            return 122
        case .momentum:
            return 107
        case .pacific:
            return 162
        case .re:
            return 101
        case .remort:
            return 102
        case .sc:
            return 143
        case .scgrow:
            return 145
        case .scval:
            return 144
        case .stgov:
            return 119
        case .tech:
            return 176
        case .tips:
            return 123
        case .total:
            return 136
        case .mc:
            return 140
        case .mcgrow:
            return 142
        case .mcval:
            return 141
        }
    }
}
