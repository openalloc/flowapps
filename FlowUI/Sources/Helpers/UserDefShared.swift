//
//  UserDefShared.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation

public enum UserDefShared: String {
    case userAgreedTermsAt
    case timeZoneID
    case defTimeOfDay
    case versionNotice
    
    public static func value<T>(_ key: UserDefShared) -> T? {
        let val: T? = fromUserDefaults(key.rawValue)
        return val
    }
    
    public static func value<T>(_ keyStr: String, _ defVal: T) -> T {
        let val: T? = fromUserDefaults(keyStr)
        return val ?? defVal
    }
    
    internal static func fromUserDefaults<T>(_ keyStr: String) -> T? {
        if let val = UserDefaults.standard.value(forKey: keyStr) as? T {
            return val
        }
        return nil
    }
}
