//
//  String-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension String {
    /*
     Create a string by writing to output stream via closure.

     Example:

     let csvString = String.createByWrite(capacity: 5000) { outputStream in
         do {
            try Project.generateCSV(outputStream, [project])
         } catch let error as NSError {
             //print("Ooops! Something went wrong: \(error)")
         }
     }
     */
    static func createByWrite(capacity maxLength: Int, body: (OutputStream) -> Void) -> String {
        var buffer = [UInt8](repeating: 0, count: maxLength)
        buffer.withUnsafeMutableBufferPointer { (real: inout UnsafeMutableBufferPointer<UInt8>) in
            let stream = OutputStream(toBuffer: real.baseAddress!, capacity: maxLength)
            stream.open()
            body(stream)
            stream.close()
        }
        return String(cString: buffer)
    }
}
