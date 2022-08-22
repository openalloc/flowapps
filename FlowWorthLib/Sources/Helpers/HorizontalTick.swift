//
//  HorizontalTick.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase

public struct HorizontalTick: Identifiable, Hashable {
    public let id: UUID
    public let timestamp: Date
    public let offset: CGFloat // 0...1
    public let showLabel: Bool
    
    public init(id: UUID, timestamp: Date, offset: CGFloat, showLabel: Bool) {
        self.id = id
        self.timestamp = timestamp
        self.offset = offset
        self.showLabel = showLabel
    }
    
    /// one tick per timestamp
    public static func getTicks(timestamps: [Date], labelWidth: CGFloat = 0.1, minSpace: CGFloat = 0.01) -> [HorizontalTick] {
        guard let start = timestamps.first,
              let end = timestamps.last else { return [] }
        
        let interval = DateInterval(start: start, end: end)
        guard interval.duration > 0 else { return [] } // avoid crash when offset==NaN
        
        let offsets: [CGFloat] = timestamps.map {
            let sinceStart = $0.timeIntervalSince(start)
            return CGFloat(sinceStart / interval.duration)
        }
        
        let availWidth = offsets.last ?? 0
        let labelSpacer = LabelSpacer(tickPositions: offsets,
                                      availWidth: availWidth,
                                      labelWidth: labelWidth,
                                      minSpace: minSpace)

        return zip(timestamps, offsets, labelSpacer.showLabel).reduce(into: []) {
            $0.append(HorizontalTick(id: UUID(), timestamp: $1.0, offset: $1.1, showLabel: $1.2))
        }
    }
    
    // generate relative widths from real widths
    public static func getTicks(timestamps: [Date],
                         width: CGFloat,
                         labelWidth: CGFloat = 70,
                         minSpace: CGFloat = 5) -> [HorizontalTick] {
        let relLabelWidth: CGFloat = labelWidth / width
        let relMinSpace: CGFloat = minSpace / width
        return HorizontalTick.getTicks(timestamps: timestamps, labelWidth: relLabelWidth, minSpace: relMinSpace)
    }

}

