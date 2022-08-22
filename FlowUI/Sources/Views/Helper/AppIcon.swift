//
//  AppIcon.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

extension Bundle {
    var iconFileName: String? {
        #if os(iOS)
            guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
                  let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
                  let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
                  let iconFileName = iconFiles.last
            else { return nil }
            return iconFileName
        #elseif os(macOS)
            guard let iconFileName = infoDictionary?["CFBundleIconFile"] as? String
            else { return nil }
            return iconFileName
        #endif
    }
}

public struct AppIcon: View {
    
    public init() {}
    
    public var body: some View {
        #if os(iOS)
            Bundle.main.iconFileName
                .flatMap { UIImage(named: $0) }
                .map { Image(uiImage: $0) }
        #elseif os(macOS)
            Bundle.main.iconFileName
                .flatMap { NSImage(named: $0) }
                .map { Image(nsImage: $0) }
        #endif
    }
}
