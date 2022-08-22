//
//  InfoMessageStore.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

// used to message content view from other threads
public struct InfoMessagePayload {
    public let modelID: UUID
    public let messages: [InfoMessageStore.Message]

    public init(modelID: UUID, messages: [InfoMessageStore.Message]) {
        self.modelID = modelID
        self.messages = messages
    }
}

// NOTE that the InfoMessageStore will accumulate messages for ALL OPEN DOCUMENTS,
// and so will need to filter by document modelID to display the correct messages
// each open document.

public final class InfoMessageStore: ObservableObject {
    
    public typealias MessagesMap = [UUID: [Message]]
    
    public struct Message: Identifiable {
        public let id: UUID
        public let val: String
        public let schemaName: String?
        public let rejectedRows: [AllocRowed.DecodedRow]

        public init(id: UUID = UUID(),
                    val: String,
                    schemaName: String? = nil,
                    rejectedRows: [AllocRowed.DecodedRow] = []) {
            self.id = id
            self.val = val
            self.schemaName = schemaName
            self.rejectedRows = rejectedRows
        }
    }

    // messages mapped by each document model id
    @Published private var messagesMap: MessagesMap
    
    public init(messagesMap: MessagesMap = [:]) {
        self.messagesMap = messagesMap
    }
    
    public func messages(modelID: UUID) -> [Message] {
        messagesMap[modelID, default: []]
    }
        
    public func hasMessages(modelID: UUID) -> Bool {
        messages(modelID: modelID).count > 0
    }
    
    public func add(_ nuMessage: String, modelID: UUID, schemaName: String? = nil) {
        let message = Message(val: nuMessage, schemaName: schemaName)
        add(contentsOf: [message], modelID: modelID)
    }
    
    public func add(contentsOf nuMessages: [Message], modelID: UUID) {
        messagesMap[modelID, default: []].append(contentsOf: nuMessages)
    }
    
    public func dismiss(modelID: UUID) {
        messagesMap[modelID, default: []].removeAll()
    }
}


