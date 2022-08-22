//
//  LabelSpacer.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// ignores margins outside available width -- first and last labels only need half-width
// requires first label, regardless of spacing
// if more than one position, include last label, if space

public final class LabelSpacer {
    
    public let tickPositions: [CGFloat]
    public let availWidth: CGFloat
    public let labelWidth: CGFloat
    public let minSpace: CGFloat
    
    public init(tickPositions: [CGFloat],
                availWidth: CGFloat,
                labelWidth: CGFloat,
                minSpace: CGFloat) {
        self.tickPositions = tickPositions
        self.availWidth = availWidth
        self.labelWidth = labelWidth
        self.minSpace = minSpace
    }
    
    internal lazy var halfLabelWidth: CGFloat = {
        labelWidth / 2
    }()
        
    public lazy var showLabel: [Bool] = {
        
        // x represents the trailing edge of the last rendered label plus space, if any
        var x: CGFloat = -halfLabelWidth
        
        return tickPositions.reduce(into: []) { array, pos in
        
            let inBounds = pos <= availWidth && x <= availWidth
            
            // can we fit half a label, up to pos?
            let isRoom = (x + halfLabelWidth <= pos)
        
            let canFit = inBounds && isRoom
            
            array.append(canFit)
            
            // new trailing edge
            if canFit {
                x = pos + halfLabelWidth + minSpace
            }
        }
    }()
}
