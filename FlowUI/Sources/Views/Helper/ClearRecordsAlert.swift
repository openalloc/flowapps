//
//  ClearRecordsAlert.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import FlowBase

struct ClearRecordsAlert: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String
    let onClear: OnClear?

    var body: some View {
        VStack {
            Text(title).font(.title)

            Text("This will delete all records.")
                .padding()
        }
        .padding()
        .toolbar {
            ToolbarItemGroup(placement: .destructiveAction) {
                deleteButton
            }
            ToolbarItemGroup(placement: .cancellationAction) {
                cancelButton
            }
        }
    }

    private var cancelButton: some View {
        Button(action: cancelAction) {
            Text("Cancel")
        }
        .frame(minWidth: 100)
        .keyboardShortcut(.cancelAction)
    }

    private var deleteButton: some View {
        Button(action: clearAction) {
            Text("Delete")
        }
        .frame(minWidth: 100)
    }

    // MARK: - Actions

    private func cancelAction() {
        //print("cancelAction")
        dismissAction()
    }

    private func dismissAction() {
        presentationMode.wrappedValue.dismiss()
    }

    private func clearAction() {
        onClear?()

        dismissAction()
    }
}
