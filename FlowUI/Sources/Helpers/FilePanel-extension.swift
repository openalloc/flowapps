//
//  FilePanel-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

// NOTE MacOS only
// NOTE Adapted from Alfian Losari

import Cocoa

public extension NSOpenPanel {
    static func importURLs(completion: @escaping (_ result: Result<[URL], Error>) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        //panel.allowedFileTypes = ["csv", "tsv"]  // deprecated in MacOS 12
        panel.allowedContentTypes = [.commaSeparatedText, .tabSeparatedText, .utf8TabSeparatedText]
        panel.canChooseFiles = true
        panel.begin { result in
            if result == .OK {
                completion(.success(panel.urls))
            } else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
            }
        }
    }
}

public extension NSSavePanel {
    static func saveData(_ data: Data, name: String, ext: String, completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "\(name).\(ext)"
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { result in
            guard result == .OK,
                  let url = savePanel.url
            else {
                completion(.failure(
                    NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get file location"])
                ))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try data.write(to: url)
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
}
