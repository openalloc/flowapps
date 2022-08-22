//
//  Zip3Generator.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// zip - via https://gist.github.com/JRHeaton/ff5addcd72f221dd57ad

public struct Zip3Generator
    <
    A: IteratorProtocol,
    B: IteratorProtocol,
    C: IteratorProtocol
>: IteratorProtocol {

    private var first: A
    private var second: B
    private var third: C

    private var index = 0

    init(_ first: A, _ second: B, _ third: C) {
        self.first = first
        self.second = second
        self.third = third
    }

    // swiftlint:disable large_tuple
    mutating public func next() -> (A.Element, B.Element, C.Element)? {
        if let first = first.next(), let second = second.next(), let third = third.next() {
            return (first, second, third)
        }
        return nil
    }
}

public func zip<A: Sequence, B: Sequence, C: Sequence>(_ first: A, _ second: B, _ third: C) -> IteratorSequence<Zip3Generator<A.Iterator, B.Iterator, C.Iterator>> {
    return IteratorSequence(Zip3Generator(first.makeIterator(), second.makeIterator(), third.makeIterator()))
}
