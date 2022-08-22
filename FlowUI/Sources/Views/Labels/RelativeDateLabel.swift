//
//  RelativeDateLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import Compactor

public struct RelativeDateLabel: View {
    var timeInterval: TimeInterval

    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    static let timeCompactor: TimeCompactor = {
        TimeCompactor(ifZero: "", style: .full)
    }()

    public var body: some View {
        Text(RelativeDateLabel.timeCompactor.string(from: timeInterval as NSNumber) ?? "")
    }
}


