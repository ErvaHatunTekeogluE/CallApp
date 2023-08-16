//
//  ChannelView.swift
//  CallingAgora_App
//
//  Created by Erva Hatun Tekeoğlu on 15.08.2023.
//

import SwiftUI

struct ChannelView: View {
    @ObservedObject var agoraManager = AgoraManager(
        appId: DocsAppConfig.shared.appId, role: .broadcaster
    )
    
    @State var volumeSetting: [UInt: Bool] = [:]
    @State var muteSetting: [UInt: Bool] = [:]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(Array(agoraManager.allUsers), id: \.self) { uid in
                    AgoraVideoCanvasView(manager: agoraManager, uid: uid)
                        .aspectRatio(contentMode: .fit).cornerRadius(10)
                    .overlay( alignment: .bottom,content: {
                            HStack(spacing: 10) {
                                CircularButton(imageName: (muteSetting[uid] ?? false) ? "mic.slash.fill" : "mic.fill") {
                                    if self.muteSetting[uid] == nil {
                                        self.muteSetting[uid] = false
                                    }
                                    self.muteSetting[uid]?.toggle()
                                    agoraManager.setMic(for: uid, to: self.muteSetting[uid] ?? false)
                                }.disabled(uid != agoraManager.localUserId)
                                
//                                CircularButton(imageName: (volumeSetting[uid] ?? true) ? "speaker.wave.3.fill" : "speaker.slash.fill") {
//                                    if self.volumeSetting[uid] == nil {
//                                        self.volumeSetting[uid] = true
//                                    }
//                                    self.volumeSetting[uid]?.toggle()
//                                    agoraManager.setVolume(for: uid, to: self.volumeSetting[uid] ?? true)
//                                }
                            }.padding(.all,5)
                                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        })
                }
            }.padding(20)
        }
        .task {
            await agoraManager.joinChannel(DocsAppConfig.shared.channel.trimmingCharacters(in: .whitespaces))
        }.onDisappear {
            agoraManager.leaveChannel()
        }
    }
    func setAudio(uid: UInt){
       // volumeBinding(for: uid)
       
       
    }
    
    func setVideo(isMute: Bool){
      // self.agoraEngine.muteLocalVideoStream(isMute)
    }
}

struct CircularButton: View {
    var imageName: String
    var action: ()-> ()
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.all,10)
                .background(Circle().foregroundColor(.blue))
                .foregroundColor(.white)
        }
    }
}
