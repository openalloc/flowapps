//
//  MustAcknowledgeTerms.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MustAcknowledgeTerms: View {
    
    public init() {}
    
    public var body: some View {
        GroupBox {
            VStack(alignment: .center) {
                Group {
                    Text("You will need to agree to ‘Terms and Conditions’ to enable basic functionality.")
                        .font(.title2)
                    #if os(macOS)
                    Button(action: {
                        NotificationCenter.default.post(name: .showTerms, object: nil)
                    }, label: {
                        Text("Review ‘Terms and Conditions’")
                    })
                    #else
                    NavigationLink(
                        destination: TermsView(showTerms: $showTerms, onUpdate: {
                            NotificationCenter.default.post(name: .showTerms, object: nil)
                        }),
                        label: {
                            Text("Review ‘Terms and Conditions’")
                        })
                    #endif
                }
                .padding()
            }
        }
    }
}
