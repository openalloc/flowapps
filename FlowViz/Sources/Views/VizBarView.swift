//
//  VizBarView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct BlockShape: Shape {
    var block: FencedArea.Block

    func path(in rect: CGRect) -> Path {
        var p = Path()

        let blockHeight = rect.height
        let blockWidth = rect.width * block.width
        let x = rect.width * CGFloat(block.start)

        p.move(to: CGPoint(x: x, y: 0))
        p.addLine(to: CGPoint(x: x, y: blockHeight))
        p.addLine(to: CGPoint(x: x + blockWidth, y: blockHeight))
        p.addLine(to: CGPoint(x: x + blockWidth, y: 0))

        p.closeSubpath()

        return p
    }
}

class FencedArea {
    struct Block: Hashable {
        /// The block's width, as a proportion of 1
        var width: CGFloat
        /// The ring's hue.
        var hue: Color

        /// The block's start location, as a percentage.
        fileprivate(set) var start = CGFloat(0.0)
        /// The block's end location, as a percentage.
        fileprivate(set) var end = CGFloat(0.0)
    }

    private var location = CGFloat(0)
    var blocks = [Block]()

    func addBlock(width: CGFloat, hue: Color) {
        let start = location
        location += width
        let end = location
        blocks.append(Block(width: width, hue: hue, start: start, end: end))
    }
}

struct BlockView: View {
    var fencedArea: FencedArea

    var body: some View {
        ZStack {
            ForEach(fencedArea.blocks, id: \.self) { block in
                BlockShape(block: block).fill(block.hue)
            }
        }
        .compositingGroup() // flattens so shadowing makes sense
    }
}

public struct VizBarView: View {

    private var fencedArea = FencedArea()

    public init(_ slices: [VizSlice]) {
        for slice in slices {
            fencedArea.addBlock(
                width: slice.targetPct,
                hue: slice.color
            )
        }
    }

    public var body: some View {
        BlockView(fencedArea: fencedArea)
    }
}

 struct VizBarView_Previews: PreviewProvider {

    struct TestHolder: View {

        var slices: [VizSlice]

        var body: some View {
            NavigationView {
                VizBarView(slices)
                    .frame(height: 15)
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

