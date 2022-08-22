//
//  Types.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowBase

public typealias AnyViewContent = () -> AnyView
public typealias CanDelete<T> = (T?) -> Bool
public typealias FancyFormatter<T> = (T) -> String
public typealias FancyParser<T> = (String) -> T?
public typealias FetchAssetValues = (AccountKey) -> [AssetValue]
public typealias IsChecked<T> = (T) -> Bool
public typealias OnCheck<T> = ([T], Bool) -> Void
public typealias OnCheckAll = (Bool) -> Void
public typealias OnClear = () -> Void
public typealias OnCommit = () -> Void
public typealias OnDelete<T> = (T) -> Void
public typealias OnDismiss = () -> Void
public typealias OnEditingChanged = (Bool) -> Void
public typealias OnExport = () -> Void
public typealias OnFilter<T> = (T) -> Bool
public typealias OnLoad = () -> Void
public typealias OnMove = (IndexSet, Int) -> Void
public typealias OnSave<T> = () throws -> Void
public typealias OnSelect<T> = (T) -> Void
public typealias PlainFormatter<T> = (T) -> String


