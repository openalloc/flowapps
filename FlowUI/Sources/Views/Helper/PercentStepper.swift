//
//  PercentStepper.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public typealias OnStepperChanged = () -> Void

public struct PercentStepper: View {
    
    // MARK: - Parameters
    
    @Binding private var value: Double
    private var range: ClosedRange<Double>
    private var step: Double
    private var onChanged: OnStepperChanged?
    
    public init(value: Binding<Double>,
                in range: ClosedRange<Double> = 0...1,
                step: Double = 0.001,
                debounceMilliSecs: Int = 1000,
                onChanged: OnStepperChanged? = nil)
    {
        _value = value
        self.range = range
        self.step = step
        self.onChanged = onChanged

        proxy = DebouncedHolder<Double>(initialValue: value.wrappedValue, milliseconds: debounceMilliSecs)
    }

    // MARK: - Locals
    
    @ObservedObject private var proxy: DebouncedHolder<Double>

    // MARK: - Views

    public var body: some View {
        Stepper(value: self.$proxy.value,
                in: range,
                step: step,
                onEditingChanged: { isInFocus in
            if isInFocus { return }
        }, label: {
            //PercentLabel(value: proxy.value) NOTE caused issues in form
            Text("\(proxy.value.toPercent1())")
        })
        .onReceive(proxy.didChange) {
            if value != proxy.value {
                value = proxy.value
                onChanged?()
            }
        }
    }
}
