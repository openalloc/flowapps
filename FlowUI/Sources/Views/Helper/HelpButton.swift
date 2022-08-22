//
//  HelpButton.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct HelpButton: View {
    @Environment(\.openURL) var openURL
    
    var appName: String
    var topicName: String

    public init(appName: String, topicName: String) {
        self.appName = appName
        self.topicName = topicName
    }
    
    public var body: some View {
        
        Button(action: {
            openURL(url)
        })
        {
            buttonLook
        }
        .buttonStyle(BorderlessButtonStyle())
    }
               
    // https://openalloc.github.io/allocator/holdingsParticipation/index.html
    private var url: URL {
        URL(string: "https://openalloc.github.io/\(appName)/\(topicName)/index.html")!
    }

    private var buttonLook: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.accentColor.opacity(0.8))
            Image(systemName: "questionmark")
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
    }
}

//struct HelpButton_Previews: PreviewProvider {
//    static var previews: some View {
//        HelpButton(appName: "allocator", topicName: "optimize")
//    }
//}
