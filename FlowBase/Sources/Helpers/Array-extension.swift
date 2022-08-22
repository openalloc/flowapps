//
//  Array+Extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Array {
    mutating func move(at index: Index, to newIndex: Index) {
        insert(remove(at: index), at: newIndex)
    }
}

extension Array: Comparable where Element: Comparable {
    public static func < (lhs: [Element], rhs: [Element]) -> Bool {
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if leftElement < rightElement {
                return true
            } else if leftElement > rightElement {
                return false
            }
        }
        return lhs.count < rhs.count
    }
}

extension Array {
    func decompose() -> (Iterator.Element, [Iterator.Element])? {
        guard let x = first else { return nil }
        return (x, Array(self[1 ..< count]))
    }
}

private func between<T>(x: T, _ ys: [T]) -> [[T]] {
    guard let (head, tail) = ys.decompose() else { return [[x]] }
    return [[x] + ys] + between(x: x, tail).map { [head] + $0 }
}

public extension Array where Element: Hashable {
    
    @inlinable
    var isUnique: Bool {
        var seen = Set<Element>()
        return allSatisfy { seen.insert($0).inserted }
    }
}

// via https://stackoverflow.com/posts/51683055/revisions
public extension Array where Element: Equatable {
    
    @inlinable
    func reorder(by preferredOrder: [Element]) -> [Element] {
        sorted { a, b -> Bool in
            guard let first = preferredOrder.firstIndex(of: a) else {
                return false
            }

            guard let second = preferredOrder.firstIndex(of: b) else {
                return true
            }

            return first < second
        }
    }
}

public extension Array {

    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    @inlinable
    func item(at index: Int, default: Element? = nil) -> Element? {
        indices.contains(index) ? self[index] : `default`
    }
    
    @inlinable
    func item(at index: Int, default: Element) -> Element {
        indices.contains(index) ? self[index] : `default`
    }
}
