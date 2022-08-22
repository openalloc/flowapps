//
//  Color-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

extension Color {
    
#if canImport(UIKit)
    private typealias NativeColor = UIColor
#elseif canImport(AppKit)
    private typealias NativeColor = NSColor
#endif
    
    /// transform a dynamic color to a componentized one, so its components can be fetched and manipulated
    public static func componentize(_ rawColor: Color) -> Color {
        let nativeColor = NativeColor(rawColor)
        guard nativeColor.type == .catalog && nativeColor.catalogNameComponent.description == "#$customDynamic" else { return rawColor }
        return Color(nativeColor.usingColorSpace(.genericRGB)!)
    }
    
    private var components: (h: CGFloat, s: CGFloat, b: CGFloat, o: CGFloat) {
        
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        let nativeColor = NativeColor(self)
        nativeColor.getHue(&h, saturation: &s, brightness: &b, alpha: &o)
        
        return (h, s, b, o)
    }
    
    public func saturate(by percent: CGFloat = 0.1) -> Color {
        let c = self.components
        return Color(hue: c.h,
                     saturation: clipUnit(c.s - percent),
                     brightness: c.b, //clipUnit(c.b - percent),
                     opacity: c.o)
    }
    public func desaturate(by percent: CGFloat = 0.1) -> Color {
        saturate(by: -1 * abs(percent))
    }
    
    public func lighten(by percent: CGFloat = 0.1) -> Color {
        let c = self.components
        return Color(hue: c.h,
                     saturation: c.s, //clipUnit(c.s - percent),
                     brightness: clipUnit(c.b - percent),
                     opacity: c.o)
    }
    public func darken(by percent: CGFloat = 0.1) -> Color {
        lighten(by: -1 * abs(percent))
    }
    
    public static func palette(start: Color, end: Color, steps: Int = 5) -> [Color] {
        guard steps > 0 else { return [] }
        let s = start.components
        let e = end.components
        let interval = 1.0 / Double(steps)
        return stride(from: 0.0, through: 1.0, by: interval).map {
            Color(hue: lerp(s.h, e.h, by: $0),
                  saturation: lerp(s.s, e.s, by: $0),
                  brightness: lerp(s.b, e.b, by: $0),
                  opacity: lerp(s.o, e.o, by: $0))
        }
    }
    
    /// Linearly interpolate from `from` to `to` by the fraction `amount`.
    internal static func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
        fromValue + (toValue - fromValue) * amount
    }
    
    internal func clipUnit<T: BinaryFloatingPoint>(_ v: T) -> T {
        clip(v, 0.0, 1.0)
    }
    
    internal func clip<T: Comparable>(_ v: T, _ minimum: T, _ maximum: T) -> T {
        max(min(v, maximum), minimum)
    }
}

