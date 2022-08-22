//
//  Holder.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import Foundation

/// Holder holds an observable, NON-optional object reference
///
public final class DebouncedHolder<T: Equatable>: ObservableObject {
    public let didChange = PassthroughSubject<Void, Never>()
    let descript: String

    @Published public var value: T

    private var debounceCancellable: AnyCancellable?

    public init(initialValue value: T, milliseconds: Int = 500, _ descript: String = "") {
        self.value = value
        self.descript = descript

        debounceCancellable = $value
            .debounce(for: .milliseconds(milliseconds), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { _ in
                self.didChange.send()
            })
    }

    // TODO ensure this is atomic (somehow)
    /// assign a new value, returning the old value
    func setValue(newValue: T) -> T {
        let oldValue = value
        value = newValue
        return oldValue
    }
}
