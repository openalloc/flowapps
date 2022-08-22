//
//  BaseModel+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension BaseModel {
    func validate() throws {
        try accounts.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try allocations.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try strategies.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try assets.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try securities.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try holdings.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try trackers.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try caps.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
        try transactions.forEach {
            try $0.validate(against: self, isNew: false)
            try $0.validate()
        }
    }
}
