//
//  BaseModel+ImportResult.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter
import FINporterFido
import FINporterTabular
import FINporterChuck
import FINporterAllocSmart

extension BaseModel {
    
    public struct ImportResult {
        public var url: URL?
        public var allocSchema: AllocSchema?
        public var rejectedRows: [AllocRowed.DecodedRow] = []
        public var exportedAt: Date?
        public var errorMessage: String?
        
        public var hasIssue: Bool { errorMessage != nil || rejectedRows.count > 0 }
        
        public var warningDescription: String? {
            guard let filename = url?.lastPathComponent else { return nil }
            var buffer: [String] = ["WARN: \(filename)"]
            if let schemaName = allocSchema?.camelCasePluralName {
                buffer.append(schemaName)
            }
            if let warningMsg = errorMessage {
                buffer.append(warningMsg)
            }
            return buffer.joined(separator: " ")
        }
    }
    
    /// verify "00:00" through "23:59"
    static public func normalizeTimeOfDay(_ str: String?) -> String? {
        guard let _str = str?.trimmingCharacters(in: .whitespacesAndNewlines),
              _str.count == 5
        else { return nil }
        // TODO use regex matcher
        return _str
    }
    
    mutating public func importData(urls: [URL],
                                    timeZone: TimeZone = TimeZone.current,
                                    defTimeOfDay: String? = nil) -> [ImportResult] {
        urls.reduce(into: []) { array, url in
            
            var warnMsg: String? = nil
            do {
                let results: [BaseModel.ImportResult] = try detectDecodeImport(url: url, timeZone: timeZone, defTimeOfDay: defTimeOfDay)
                if results.count > 0 {
                    array.append(contentsOf: results)
                } else {
                    warnMsg = "Content not recognized."
                }
            } catch let error as AllocDataError {
                warnMsg = error.description
            } catch let error as FINporterError {
                warnMsg = error.description
            } catch let error as StorageManagerError {
                warnMsg = error.description
            } catch let error as FlowBaseError {
                warnMsg = error.description
            } catch {
                warnMsg = "\(error)"
            }
            
            return array.append(ImportResult(url: url, errorMessage: warnMsg))
        }
    }
    
    internal mutating func getImportResult(url: URL?,
                                           data: Data,
                                           finPorter: FINporter,
                                           allocSchema: AllocSchema,
                                           exportedAt: Date?,
                                           timeZone: TimeZone,
                                           defTimeOfDay: String?) throws -> ImportResult {
        var rejectedRows: [AllocRowed.RawRow] = []
        try importHordes(data,
                         finPorter: finPorter,
                         schema: allocSchema,
                         rejectedRows: &rejectedRows,
                         url: url,
                         timestamp: exportedAt,
                         timeZone: timeZone,
                         defTimeOfDay: defTimeOfDay)
        return ImportResult(url: url,
                            allocSchema: allocSchema,
                            rejectedRows: rejectedRows,
                            exportedAt: exportedAt)
    }
    
    internal mutating func detectDecodeImport(url: URL,
                                              timeZone: TimeZone = TimeZone.current,
                                              defTimeOfDay: String? = nil) throws -> [ImportResult] {
        let data = try Data(contentsOf: url)
        return try detectDecodeImport(data: data, url: url, timeZone: timeZone, defTimeOfDay: defTimeOfDay)
    }
    
    public mutating func detectDecodeImport(data: Data,
                                            url: URL? = nil,
                                            timeZone: TimeZone = TimeZone.current,
                                            defTimeOfDay: String? = nil) throws -> [ImportResult] {
        let sourceFormats: [AllocFormat] = [.CSV, .TSV]
        let prospector = FINprospector([
            AllocSmart(),
            FidoHistory(),
            FidoPositions(),
            FidoSales(),
            ChuckPositionsAll(),
            ChuckPositionsIndiv(),
            ChuckHistory(),
            ChuckSales(),
            Tabular(),
        ])
        
        // Multiple importers may be able to contribute.
        // Each importer may produce data for more than one schema.
        let prospectResult: FINprospector.ProspectResult = try prospector.prospect(sourceFormats: sourceFormats, dataPrefix: data)
        
        var exportedAt: Date? = nil
        var results = [ImportResult]()
        
        for (finPorter, detectResults) in prospectResult {
            
            // if present, grab the export date from the metadata
            if detectResults.first(where: { $0.key == .allocMetaSource }) != nil {
                var rejectedRows: [AllocRowed.RawRow] = []
                let items: [AllocRowed.DecodedRow] = try finPorter.decode(MSourceMeta.self, data, rejectedRows: &rejectedRows, outputSchema: .allocMetaSource)
                if let item = items.first,
                   let _exportedAt = item["exportedAt"] as? Date {
                    exportedAt = _exportedAt
                }
            }
            
            for detectResult in detectResults {
                let allocSchema = detectResult.key
                guard allocSchema != .allocMetaSource else { continue }
                let result = try getImportResult(url: url,
                                                 data: data,
                                                 finPorter: finPorter,
                                                 allocSchema: allocSchema,
                                                 exportedAt: exportedAt,
                                                 timeZone: timeZone,
                                                 defTimeOfDay: defTimeOfDay)
                results.append(result)
            }
            
            exportedAt = nil  // clear it (because it may be irrelevant to next file)
        }
        
        return results
    }
}
