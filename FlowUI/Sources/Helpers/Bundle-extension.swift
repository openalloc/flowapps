//
//  Bundle+Extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation


extension Bundle {
    var applicationName: String? {
        guard let dictionary = Bundle.main.infoDictionary else { return nil }
        return (dictionary["CFBundleDisplayName"] as? String) ?? (dictionary["CFBundleName"] as? String)
    }
}

