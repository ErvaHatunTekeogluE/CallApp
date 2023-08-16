//
//  NoiceCancellationView.swift
//  CallingAgora_App
//
//  Created by Erva Hatun Tekeoğlu on 15.08.2023.
//

import AVFoundation
import Foundation

import Koala
import ios_voice_processor
import SwiftUI
import AgoraRtcKit
//class KoalaManager: ObservableObject {
//    
//    private var koala: Koala!
//    
//    @Published var errorMessage = ""
//    init() {
//        let accessKey = "XXEdyPCdTAiLCR17PzCnQtsHtL1IrVmSmuDVNZIxjTEEvypF7TkIfw=="
//         koala = try Koala(accessKey: accessKey)
//    }
//    
//    func processAudioFrame(_ frame: AgoraAudioFrame) {
//        // Convert Agora audio frame to appropriate format
//        if let audioBuffer: AVAudioPCMBuffer = convertAgoraAudioFrameToAVAudioPCMBuffer(frame) {
//            let processedFrames = try? koala.process(audioBuffer)
//            
//        }
//        
//    }
//    
//    func convertAgoraAudioFrameToAVAudioPCMBuffer(_ audioFrame: AgoraAudioFrame) -> AVAudioPCMBuffer? {
//        // Assuming audioFrame.buffer contains raw audio data in Int16 format
//        let audioData = Data(bytes: audioFrame.buffer, count: Int(audioFrame.samples * 2))
//        
//        guard let format = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: Double(audioFrame.samplesPerSec), channels: 1, interleaved: false) else {
//            return nil
//        }
//        
//        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(audioFrame.samples)) else {
//            return nil
//        }
//        
//        pcmBuffer.frameLength = pcmBuffer.frameCapacity
//        
//        let audioBuffer = pcmBuffer.int16ChannelData?[0]
//        audioData.withUnsafeBytes { (pointer: UnsafePointer<Int16>) in
//            if let pointer = pointer.baseAddress {
//                audioBuffer?.assign(from: pointer, count: Int(audioFrame.samples))
//            }
//        }
//        
//        return pcmBuffer
//    }
//}
