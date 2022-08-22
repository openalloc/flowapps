//
//  WedgeGeometry.swift
//

import SwiftUI

/*
 Copyright © 2019 Apple Inc.

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/// Helper type for creating view-space points within a wedge.
struct WedgeGeometry {
    var wedge: Ring.Wedge
    var center: CGPoint
    var innerRadius: CGFloat
    var outerRadius: CGFloat

    init(_ wedge: Ring.Wedge, in rect: CGRect) {
        self.wedge = wedge
        center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) * 0.5
        innerRadius = radius * 2 / 3
        outerRadius = innerRadius +
            (radius - innerRadius) * CGFloat(wedge.depth)
    }

    /// Returns the view location of the point in the wedge at unit-
    /// space location `unitPoint`, where the X axis of `p` moves around the
    /// wedge arc and the Y axis moves out from the inner to outer
    /// radius.
    subscript(unitPoint: UnitPoint) -> CGPoint {
        let radius = lerp(innerRadius, outerRadius, by: unitPoint.y)
        let angle = lerp(wedge.start, wedge.end, by: Double(unitPoint.x))

        return CGPoint(x: center.x + CGFloat(cos(angle)) * radius,
                       y: center.y + CGFloat(sin(angle)) * radius)
    }
}

/// Linearly interpolate from `from` to `to` by the fraction `amount`.
func lerp<T: BinaryFloatingPoint>(_ fromValue: T, _ toValue: T, by amount: T) -> T {
    return fromValue + (toValue - fromValue) * amount
}
