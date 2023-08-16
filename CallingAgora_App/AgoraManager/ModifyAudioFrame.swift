//
//  ModifyAudioFrame.swift
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

public class ModifyAudioFrameDelegate: NSObject, AgoraAudioFrameDelegate {
    private var koala: Koala!
    
    @Published var errorMessage = ""
    override init() {
        let accessKey = "XXEdyPCdTAiLCR17PzCnQtsHtL1IrVmSmuDVNZIxjTEEvypF7TkIfw=="
        
        do {
            try koala = Koala(accessKey: accessKey)
        } catch let error as KoalaInvalidArgumentError {
            errorMessage = "\(error.localizedDescription)\nEnsure your AccessKey '\(accessKey)' is valid."
        } catch is KoalaActivationError {
            errorMessage = "ACCESS_KEY activation error"
        } catch is KoalaActivationRefusedError {
            errorMessage = "ACCESS_KEY activation refused"
        } catch is KoalaActivationLimitError {
            errorMessage = "ACCESS_KEY reached its limit"
        } catch is KoalaActivationThrottledError {
            errorMessage = "ACCESS_KEY is throttled"
        } catch {
            errorMessage = "\(error)"
        }
    }
    
    public func onRecordAudioFrame(_ audioFrame: AgoraAudioFrame, channelId: String) -> Bool {
        do {
            guard let koala = self.koala else {
                return true
            }
           
            let totalSamples = audioFrame.samplesPerChannel * audioFrame.channels
            // Convert Agora audio frame buffer to an array of Int16
            if let audioData = audioFrame.buffer?.assumingMemoryBound(to: Int16.self) {
                let audioDataArray = Array(UnsafeBufferPointer(start: audioData, count: Int(totalSamples)))
                            
                // Process audio data with Koala
                let processedFrames = try koala.process(audioDataArray)
                        
                // Copy processedFrames back to the Agora audio frame buffer
                processedFrames.withUnsafeBytes { bufferPointer in
                if let baseAddress = bufferPointer.baseAddress {
                        audioFrame.buffer?.copyMemory(from: baseAddress, byteCount: processedFrames.count * MemoryLayout<Int16>.size)
                    }
                }
            }
        } catch {
            print("Koala processing error: \(error)")
        }
               
        return true
    }
//
//    func onPlaybackAudioFrame(_ audioFrame: AgoraAudioFrame) -> Bool {
//        // Process remote audio frame with Koala
//        if let processedFrame = processAudioFrame(audioFrame) {
//
//        }
//        return true
//    }
}
