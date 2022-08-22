//
//  StorageManager.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum StorageManagerError: Error, Equatable, CustomStringConvertible {
    case encodingError(_ msg: String)
    case decodingError(_ msg: String)
    case decodingKeyError(key: String, classType: String, _ msg: String)
    case invalidStorageKey(_ key: String, _ msg: String? = nil)

    public var localizedDescription: String { description }

    public var description: String {
        switch self {
        case let .encodingError(msg):
            return String("Failure to encode. \(msg)")
        case let .decodingError(msg):
            return String("Failure to decode. \(msg)")
        case let .decodingKeyError(key, classType, msg):
            return String("Failure to decode '\(key)' in \(classType). \(msg)")
        case let .invalidStorageKey(key, msg):
            return String("Invalid storage key '\(key)'. \(msg ?? "")")
        }
    }
}

public enum StorageManager {
    public static func encodeToJSON<T: Encodable>(_ element: T) throws -> String {
        let jsonData: Data = try StorageManager.encodeToJSON(element)
        guard let jsonStr = String(data: jsonData, encoding: .utf8) else { throw StorageManagerError.encodingError("Unable to encode to JSON.") }
        return jsonStr
    }

    public static func encodeToJSON<T: Encodable>(_ element: T) throws -> Data {
        let encoder = JSONEncoder()
        // encoder.outputFormatting = .sortedKeys    // available on 10.13 or newer
        do {
            return try encoder.encode(element)
        } catch let error as StorageManagerError {
            throw error
        } catch {
            throw StorageManagerError.encodingError("Invalid for '\(T.self)' (\(error))")
        }
    }

    public static func decode<T: Decodable>(fromJSON jsonStr: String) throws -> T {
        guard let jsonData = jsonStr.data(using: .utf8)
        else { throw StorageManagerError.decodingError("Invalid JSON (model not be UTF8)") }
        return try StorageManager.decode(fromJSON: jsonData)
    }

    // provide granular details on decoding failures
    public static func decode<T: Decodable>(fromJSON jsonData: Data) throws -> T {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: jsonData)
        } catch let DecodingError.keyNotFound(key, context) {
            throw StorageManagerError.decodingError("Could not find key '\(key.stringValue)' in \(T.self). \(context.debugDescription)")
        } catch let DecodingError.valueNotFound(_, context) {
            let key = context.codingPath.first?.stringValue ?? "unknown"
            throw StorageManagerError.decodingKeyError(key: key, classType: "\(T.self)", "\(context.debugDescription)")
        } catch let DecodingError.typeMismatch(_, context) {
            let key = context.codingPath.first?.stringValue ?? "unknown"
            throw StorageManagerError.decodingKeyError(key: key, classType: "\(T.self)", "Type mismatch. \(context.debugDescription)")
        } catch let DecodingError.dataCorrupted(context) {
            throw StorageManagerError.decodingError("Data found to be corrupted for '\(T.self)'. \(context.debugDescription)")
        } catch let error as NSError {
            throw StorageManagerError.decodingError("Error in read for '\(T.self)'. domain= \(error.domain), description=\(error.localizedDescription)")
        } catch {
            throw StorageManagerError.decodingError("Invalid for '\(T.self)' (\(error))")
        }
    }
}
