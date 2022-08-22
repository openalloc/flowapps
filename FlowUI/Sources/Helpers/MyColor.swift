//
//  MyColor.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI


public struct MyColor {
    
    public static func getBackgroundFill(_ color: Color, by amount: CGFloat = 0.2) -> AnyView {
        let lite = color.saturate(by: amount)
        let dark = color.desaturate(by: amount)
        return AnyView(
            LinearGradient(gradient: .init(colors: [lite, dark]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
}
