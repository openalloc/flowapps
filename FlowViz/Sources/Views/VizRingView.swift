//
//  VizRingView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct WedgeShape: Shape {
    var wedge: Ring.Wedge

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let g = WedgeGeometry(wedge, in: rect)
        p.addArc(center: g.center,
                 radius: g.innerRadius,
                 startAngle: .radians(wedge.start),
                 endAngle: .radians(wedge.end),
                 clockwise: false)

        p.addLine(to: g[.bottomTrailing])
        p.addArc(center: g.center,
                 radius: g.outerRadius,
                 startAngle: .radians(wedge.end),
                 endAngle: .radians(wedge.start),
                 clockwise: true)
        p.closeSubpath()
        return p
    }
}

class Ring {
    struct Wedge: Equatable {
        /// The wedge's width, as an angle in radians.
        var width: Double
        /// The wedge's cross-axis depth, in range [0,1].
        var depth: Double
        /// The ring's hue.
        var hue: Color

        /// The wedge's start location, as an angle in radians.
        var start = 0.0
        /// The wedge's end location, as an angle in radians.
        var end = 0.0
    }

    private var nextID = 0
    private var location = 0.0

    var wedges = [Int: Wedge]()
    var wedgeIDs = [Int]() // order we'll draw them in

    func addWedge(width: Double, depth: Double, hue: Color) {
        let start = location
        let id = nextID
        nextID += 1
        location += width * 2 * .pi
        let end = location
        wedges[id] = Wedge(width: width, depth: depth, hue: hue, start: start, end: end)
        wedgeIDs.append(id)
    }
}

struct WedgeView: View {
    var wedge: Ring.Wedge
    var body: some View {
        WedgeShape(wedge: wedge).fill(wedge.hue)
    }
}

public struct VizRingView: View {
    private var ring = Ring()
    private var blackRing = Ring.Wedge(width: 1.0, depth: 1.0, hue: Color.black, start: 0, end: 2 * .pi)

    public init(_ slices: [VizSlice]) {
        for slice in slices {
            ring.addWedge(
                width: slice.targetPct,
                depth: 1.0,
                hue: slice.color
            )
        }
    }

    // MARK: - Views

    public var body: some View {
        ZStack {
            ForEach(self.ring.wedgeIDs, id: \.self) { id in
                WedgeView(wedge: self.ring.wedges[id]!)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .compositingGroup() // flattens so shadowing makes sense
    }
}

struct VizRingView_Previews: PreviewProvider {
    
    struct TestHolder: View {
        
        var slices: [VizSlice]
        
        var body: some View {
            NavigationView {
                VizRingView(slices)
            }
        }
    }
    
    static var previews: some View {
        
        let slices: [VizSlice] = [
            VizSlice(0.35, Color(.systemIndigo)),
            VizSlice(0.12, Color(.blue)),
            VizSlice(0.10, Color(.green)),
            VizSlice(0.13, Color(.gray)),
            VizSlice(0.09, Color(.brown)),
            VizSlice(0.07, Color(.purple)),
            VizSlice(0.05, Color(.orange)),
            VizSlice(0.04, Color(.yellow)),
            VizSlice(0.03, Color(.systemTeal)),
            VizSlice(0.01, Color(.systemPink)),
            VizSlice(0.01, Color(.magenta)),
        ]
        
        return TestHolder(slices: slices)
            .previewLayout(.sizeThatFits)
    }
}
