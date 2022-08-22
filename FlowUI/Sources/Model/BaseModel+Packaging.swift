//
//  Packaging.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os

import ZIPFoundation

import FlowBase
import AllocData
import FINporter
import FINporterTabular

private let modelSettingsFilename = "modelSettings.json"
private let displaySettingsFilename = "displaySettings.json"
private let modelIdFilename = "id.dat"
private let modelPackageFormat: AllocFormat = .TSV

private let log = Logger(subsystem: "app.flowallocator.shared", category: "model.package")

extension BaseModel {
    
    public func package<MS, DS>(schemas: [AllocSchema], modelSettings: MS, displaySettings: DS) throws -> Data
    where MS: Encodable, DS: Encodable {
        guard let archive = Archive(accessMode: .create)
        else { throw FlowBaseError.archiveCreateFailure }
        
        let uuidStr = self.id.uuidString.data(using: .utf8)!
        try archive.addEntry(with: modelIdFilename,
                             type: .file,
                             uncompressedSize: Int64(uuidStr.count),
                             provider: { position, size -> Data in
            let range = Int(position) ..< Int(position) + size
            return uuidStr.subdata(in: range)
        })
        
        let modelSettingsData: Data = try StorageManager.encodeToJSON(modelSettings)
        try archive.addEntry(with: modelSettingsFilename,
                             type: .file,
                             uncompressedSize: Int64(modelSettingsData.count),
                             provider: { position, size -> Data in
            let range = Int(position) ..< Int(position) + size
            return modelSettingsData.subdata(in: range)
        })
        
        let displaySettingsData: Data = try StorageManager.encodeToJSON(displaySettings)
        try archive.addEntry(with: displaySettingsFilename,
                             type: .file,
                             uncompressedSize: Int64(displaySettingsData.count),
                             provider: { position, size -> Data in
            let range = Int(position) ..< Int(position) + size
            return displaySettingsData.subdata(in: range)
        })
        
        try schemas.forEach {
            guard let exportedData = try exportHordes(schema: $0, format: modelPackageFormat) else { return }
            let fileName = getFileName($0, modelPackageFormat)
            
            try archive.addEntry(with: fileName,
                                 type: .file,
                                 uncompressedSize: Int64(exportedData.count),
                                 provider: { position, size -> Data in
                let range = Int(position) ..< Int(position) + size
                return exportedData.subdata(in: range)
            })
        }
        
        return archive.data!
    }
    
    public mutating func unpackage<MS, DS>(data: Data,
                                           schemas: [AllocSchema],
                                           modelSettings: inout MS,
                                           displaySettings: inout DS) throws
    where MS: Decodable, DS: Decodable {
        guard let archive = Archive(data: data,
                                    accessMode: .read,
                                    preferredEncoding: .utf8)
        else { throw Archive.ArchiveError.unreadableArchive }
        
        for entry in archive {
            guard entry.type == .file else { continue }
            
            let rawData = try extractRawData(archive, entry)
            
            if entry.path == modelSettingsFilename {
                do {
                    modelSettings = try StorageManager.decode(fromJSON: rawData)
                } catch {
                    let msg = InfoMessageStore.Message(val: "Unable to decode model-related settings. The format has changed. No financial data has been lost.", schemaName: modelSettingsFilename)
                    reportMessage(msg)
                }
                continue
            } else if entry.path == displaySettingsFilename {
                do {
                    displaySettings = try StorageManager.decode(fromJSON: rawData)
                } catch {
                    let msg = InfoMessageStore.Message(val: "Unable to decode display-related settings. The format has changed. No financial data has been lost.", schemaName: displaySettingsFilename)
                    reportMessage(msg)
                }
                continue
            } else if entry.path == modelIdFilename {
                unpackModelID(rawData)
                continue
            }
            
            let components = entry.path.split(separator: ".").map { String($0) }
            guard components.count == 2,
                  let schema = AllocSchema.getFromCamelCasePlural(maybeCamelCasePluralName: components[0]),
                  schemas.contains(schema),
                  let format = AllocFormat.guess(fromFileExtension: components[1])
            else {
                //reportMessage("Warning: \(entry.path) not recognized")
                continue
            }
            
            // NOTE rethrow==false so document loads and error message is reported to user
            try tricky(entry, rethrow: false) {
                try unpack(format, schema, rawData)
            }
        }
    }
    
    private func tricky(_ entry: Entry,
                        rethrow: Bool,
                        _ body: () throws -> Void) rethrows {
        
        do {
            try body()
        } catch let error as AllocDataError {
            reportMessage(InfoMessageStore.Message(val: "Error: \(entry.path) failed with \(error.description)"), isError: true)
            if rethrow { throw error }
        } catch let error as StorageManagerError {
            reportMessage(InfoMessageStore.Message(val: "Error: \(entry.path) failed with \(error.description)"), isError: true)
            if rethrow { throw error }
        } catch let error as FlowBaseError {
            reportMessage(InfoMessageStore.Message(val: "Error: \(entry.path) failed with \(error.description)"), isError: true)
            if rethrow { throw error }
        } catch {
            reportMessage(InfoMessageStore.Message(val: "Error: \(entry.path) failed with \(error.localizedDescription)"), isError: true)
            if rethrow { throw error }
        }
    }
    
    private func extractRawData(_ archive: Archive, _ entry: Entry) throws -> Data {
        var rawData = Data()
        _ = try archive.extract(entry, consumer: { data in
            rawData.append(data)
        })
        return rawData
    }
    
    private func getFileName(_ schema: AllocSchema, _ format: AllocFormat) -> String {
        let camelCasePluralName = schema.camelCasePluralName
        return "\(camelCasePluralName).\(format.defaultFileExtension ?? "unknown")"
    }
    
    private mutating func unpackModelID(_ rawData: Data) {
        if let uuidStr = String(data: rawData, encoding: .utf8),
           let uuid = UUID(uuidString: uuidStr)
        {
            self.id = uuid
        }
    }
    
    private mutating func unpack(_ format: AllocFormat,
                                 _ schema: AllocSchema,
                                 _ rawData: Data) throws {
        var rejectedRows = [AllocRowed.RawRow]()
        
        let timeZone = TimeZone.current // there shouldn't be any unqualified dates to worry about
        
        try importHordes(rawData,
                         finPorter: Tabular(),
                         schema: schema,
                         rejectedRows: &rejectedRows,
                         finFormat: format,
                         timeZone: timeZone,
                         defTimeOfDay: nil)
        
        if rejectedRows.count > 0 {
            let msg = "Warning: \(rejectedRows.count) rejected rows for \(schema.camelCasePluralName)"
            let message = InfoMessageStore.Message(val: msg, rejectedRows: rejectedRows)
            reportMessage(message)
        }
    }
    
    func reportMessage(_ message: InfoMessageStore.Message, isError: Bool = false) {
        let payload = InfoMessagePayload(modelID: self.id, messages: [message])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: .infoMessage, object: payload)
        }
        
        if isError {
            log.error("\(message.val)")
        } else {
            log.info("\(message.val)")
        }
    }
}
