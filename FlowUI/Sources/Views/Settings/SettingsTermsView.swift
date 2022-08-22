//
//  SettingsTermsView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct SettingsTermsView: View {
    
    @AppStorage(userAgreedTermsAtKey) var userAgreedTermsAt: String = ""

    public init() {}
    
    @State private var updateToggle = false
    @State private var showTerms = false
    
    static let dfShort: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    static let isoDateFormatter = ISO8601DateFormatter()

    public var body: some View {
        StatsBoxView(title: "Terms & Conditions\(updateToggle ? "" : "")") {
            Group {
                if userAgreedTermsAt != "" {
                    VStack(alignment: .leading) {
                        Text("Agreement date:")
                            .padding(.bottom)
                        Text(formattedAgreedToTermsAt)
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text("Not Yet Agreed To")
                            .foregroundColor(.red)
                            .padding(.bottom)
                        Text("Functionality may be restricted until you agree to terms and conditions.")
                    }
                }
            }
            .font(.title3)
            .padding()

            Button(action: { showTerms.toggle() }, label: {
                Text("Review ‘Terms and Conditions’")
            })
                .sheet(isPresented: $showTerms) {
                    TermsView(showTerms: $showTerms, onUpdate: { updateToggle.toggle() })
                }
                .padding()

            Spacer()
        }
    }
    
    private var formattedAgreedToTermsAt: String {
        guard let acceptedDate = SettingsTermsView.isoDateFormatter.date(from: userAgreedTermsAt)
        else { return "Invalid Date" }

        return SettingsTermsView.dfShort.string(from: acceptedDate)
    }
}
