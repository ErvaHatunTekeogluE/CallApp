//
//  ContentView.swift
//  CallingAgora_App
//
//  Created by Erva Hatun Tekeoğlu on 15.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State var channelId: String = DocsAppConfig.shared.channel

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter channel id", text: $channelId).textFieldStyle(.roundedBorder).padding()
                NavigationLink(destination: ChannelView(),
                               label: { Text("Join Channel")})
                .disabled(channelId.isEmpty)
                .buttonStyle(.borderedProminent)
            }.onAppear {
                channelId = DocsAppConfig.shared.channel
            }
        }
    }
}
