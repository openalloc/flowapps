//
//  DropAction.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import os

private let log = Logger(subsystem: "app.flowallocator.shared", category: "drop")


public struct URLDropDelegate: DropDelegate {
    
    @ObservedObject public var debouncedURLs: DebouncedHolder<[URL]>
    var utiImportFile: String

    public init(utiImportFile: String = "public.file-url",
                milliseconds: Int = 750) {
        self.utiImportFile = utiImportFile
        debouncedURLs = DebouncedHolder<[URL]>(initialValue: [], milliseconds: milliseconds)
    }
    
    public func performDrop(info: DropInfo) -> Bool {
        log.info("\(#function) ENTER"); defer { log.info("\(#function) EXIT") }
        
        guard info.hasItemsConforming(to: [utiImportFile]) else {
            return false
        }

        for item in info.itemProviders(for: [utiImportFile]) {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                guard let _url = url else { return }
                DispatchQueue.main.async {
                    self.debouncedURLs.value.append(_url)
                }
            }
        }

        return true
    }
    
    public func purge() -> [URL] {
        debouncedURLs.setValue(newValue: [])
    }
}
