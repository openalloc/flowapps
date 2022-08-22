//
//  FloatingPoint+extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension BinaryFloatingPoint {
    // accuracy: Describes the maximum difference between expression1 and expression2 for these values to be considered equal.
    @inlinable
    func isEqual<T: BinaryFloatingPoint>(to other: T, accuracy: T) -> Bool {
        abs(T(self) - other) < accuracy
    }

    @inlinable
    func isNotEqual<T: BinaryFloatingPoint>(to other: T, accuracy: T) -> Bool {
        !isEqual(to: other, accuracy: accuracy)
    }

    @inlinable
    func isLess<T: BinaryFloatingPoint>(than other: T, accuracy: T) -> Bool {
        T(self).isLess(than: other) && isNotEqual(to: other, accuracy: accuracy)
    }

    @inlinable
    func isLessThanOrEqual<T: BinaryFloatingPoint>(to other: T, accuracy: T) -> Bool {
        T(self).isLess(than: other) || isEqual(to: other, accuracy: accuracy)
    }

    @inlinable
    func isGreater<T: BinaryFloatingPoint>(than other: T, accuracy: T) -> Bool {
        !isLessThanOrEqual(to: other, accuracy: accuracy)
    }

    @inlinable
    func isGreaterThanOrEqual<T: BinaryFloatingPoint>(to other: T, accuracy: T) -> Bool {
        !isLess(than: other, accuracy: accuracy)
    }

    // not using isZero, as it's defined by Swift.Math
    @inlinable
    func isEqualToZero<T: BinaryFloatingPoint>(accuracy: T) -> Bool {
        isEqual(to: 0, accuracy: accuracy)
    }
    
    @inlinable
    func isNotEqualToZero<T: BinaryFloatingPoint>(accuracy: T) -> Bool {
        !isEqualToZero(accuracy: accuracy)
    }
    
    @inlinable
    func coerceIfEqual<T: BinaryFloatingPoint>(to other: T, accuracy: T) -> T {
        isEqual(to: other, accuracy: accuracy) ? other : T(self)
    }
}
