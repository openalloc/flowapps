//
//  Notification-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Notification.Name
{
    static let refreshContext = Notification.Name("refreshContext") // payload of model UUID
    static let checkTerms = Notification.Name("checkTerms")
    static let showTerms = Notification.Name("showTerms")
    static let importURLs = Notification.Name("importURLs")
    static let infoMessage = Notification.Name("infoMessage")

    // used to invoke detail view (outside of NavigationView) (payload of DetailPayload)
    static let accountDetail = Notification.Name("accountDetail")
    static let allocationDetail = Notification.Name("allocationDetail")
    static let assetDetail = Notification.Name("assetDetail")
    static let capDetail = Notification.Name("capDetail")
    static let transactionDetail = Notification.Name("transactionDetail")
    static let holdingDetail = Notification.Name("holdingDetail")
    static let securityDetail = Notification.Name("securityDetail")
    static let strategyDetail = Notification.Name("strategyDetail")
    static let trackerDetail = Notification.Name("trackerDetail")
    static let valuationSnapshotDetail = Notification.Name("valuationSnapshotDetail")
    static let valuationPositionDetail = Notification.Name("valuationPositionDetail")
    static let valuationCashflowDetail = Notification.Name("valuationCashflowDetail")
    static let valuationAccountDetail  = Notification.Name("valuationAccountDetail")
}

