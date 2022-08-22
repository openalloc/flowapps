//
//  DataModelCommands.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import KeyWindow
import AllocData

public func getBaseDataModelViewCommand(_ baseModelEntities: [SidebarMenuIDs]) -> [DataModelViewCommand] {
    
    baseModelEntities.map { menuID in
        DataModelViewCommand(id: menuID.rawValue, title: menuID.title)
    }
}


// NOTE mirrors SidebarDataModelRows
public struct DataModelCommands: View {
    private let baseTableViewCommands: [DataModelViewCommand]
    private let onSelect: (String) -> Void
    private let auxTableViewCommands: [DataModelViewCommand]
    
    let altEventModifier: EventModifiers = [.control, .command]
    
    public init(baseTableViewCommands: [DataModelViewCommand],
                onSelect: @escaping (String) -> Void,
                auxTableViewCommands: [DataModelViewCommand] = []) {
        self.baseTableViewCommands = baseTableViewCommands
        self.onSelect = onSelect
        self.auxTableViewCommands = auxTableViewCommands
    }
    
    public var body: some View {
        Text("Data Model")

        ForEach(0..<items.count, id: \.self) { n in
            let cmd = items[n]
            Button(action: {
                onSelect(cmd.id)
            }, label: {
                Text(cmd.title)
            })
            .modify {
                if let equiv = getKeyEquiv(n) {
                    $0.keyboardShortcut(equiv, modifiers: altEventModifier)
                }
            }
        }
    }
    
    private var items: [DataModelViewCommand] {
        baseTableViewCommands + auxTableViewCommands
    }
    
    private func getKeyEquiv(_ n: Int) -> KeyEquivalent? {
        switch n {
        case 0:
            return "1"
        case 1:
            return "2"
        case 2:
            return "3"
        case 3:
            return "4"
        case 4:
            return "5"
        case 5:
            return "6"
        case 6:
            return "7"
        case 7:
            return "8"
        case 8:
            return "9"
        default:
            return nil
        }
    }
}
