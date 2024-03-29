//
//  AgoraManager.swift
//  Docs-Examples
//
//  Created by Max Cobb on 03/04/2023.
//

import AgoraRtcKit

/// ``AgoraManager`` is a class that provides an interface to the Agora RTC Engine Kit.
/// It conforms to the `ObservableObject` and `AgoraRtcEngineDelegate` protocols.
///
/// Use AgoraManager to set up and manage Agora RTC sessions, manage the client's role,
/// and control the client's connection to the Agora RTC server.
open class AgoraManager: NSObject, ObservableObject, AgoraRtcEngineDelegate {
    /// The Agora App ID for the session.
    public let appId: String
    /// The client's role in the session.
    public var role: AgoraClientRole = .audience {
        didSet { agoraEngine.setClientRole(role) }
    }
    /// Integer ID of the local user.
    @Published public var localUserId: UInt = 0

    private var engine: AgoraRtcEngineKit?
    /// The Agora RTC Engine Kit for the session.
    public var agoraEngine: AgoraRtcEngineKit {
        //if let engine { return engine }
        return setupEngine()
    }
    
    var audioFrameDelegate: ModifyAudioFrameDelegate?
    
    open func setupEngine() -> AgoraRtcEngineKit {
        let eng = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        eng.enableVideo()
        eng.setClientRole(role)
        setAudio(eng: eng)
        self.engine = eng
        return eng
    }

    /// The set of all users in the channel.
    @Published public var allUsers: Set<UInt> = []
    /// Initializes a new instance of `AgoraManager` with the specified app ID and client role.
    ///
    /// - Parameters:
    ///   - appId: The Agora App ID for the session.
    ///   - role: The client's role in the session. The default value is `.audience`.
    public init(appId: String, role: AgoraClientRole = .audience) {
        self.appId = appId
        self.role = role
    }

    /// Joins a channel, starting the connection to an RTC session.
    /// - Parameters:
    ///   - channel: Name of the channel to join.
    ///   - token: Token to join the channel, this can be nil for an weak security testing session.
    ///   - uid: User ID of the local user. This can be 0 to allow the engine to automatically assign an ID.
    ///   - info: Info is currently unused by RTC, it is reserved for future use.
    /// - Returns: Error code, 0 = success, &lt; 0 = failure.
    @discardableResult
    open func joinChannel(_ channel: String, token: String? = nil, uid: UInt = 0, info: String? = nil) -> Int32 {
        self.agoraEngine.joinChannel(
            byToken: token, channelId: channel, info: info, uid: uid
        )
    }

    @discardableResult
    /// This method is used by this app specifically. If there is a tokenURL,
    /// it will attempt to retrieve a token from there.
    /// Otherwise it will simply apply the provided token in config.json or nil.
    ///
    /// - Parameters:
    ///   - channel: Name of the channel to join.
    ///   - uid: User ID of the local user. This can be 0 to allow the engine to automatically assign an ID.
    /// - Returns: Error code, 0 = success, &lt; 0 = failure.
    internal func joinChannel(_ channel: String, uid: UInt? = nil) async -> Int32 {
        let userId = uid ?? DocsAppConfig.shared.uid
        let token = DocsAppConfig.shared.rtcToken
        return self.joinChannel(channel, token: token, uid: userId, info: nil)
    }

    /// Leaves the channel and stops the preview for the session.
    ///
    /// - Parameter leaveChannelBlock: An optional closure that will be called when the client leaves the channel.
    ///      The closure takes an `AgoraChannelStats` object as its parameter.
    ///
    ///
    /// This method also empties all entries in ``allUsers``,
    @discardableResult
    open func leaveChannel(
        leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil
    ) -> Int32 {
        let leaveErr = self.agoraEngine.leaveChannel(leaveChannelBlock)
        self.agoraEngine.stopPreview()
        defer { AgoraRtcEngineKit.destroy() }
        self.allUsers.removeAll()
        return leaveErr
    }

    /// The delegate is telling us that the local user has successfully joined the channel.
    /// - Parameters:
    ///    - engine: The Agora RTC engine kit object.
    ///    - channel: The channel name.
    ///    - uid: The ID of the user joining the channel.
    ///    - elapsed: The time elapsed (ms) from the user calling `joinChannel` until this method is called.
    ///
    /// If the client's role is `.broadcaster`, this method also adds the broadcaster's
    /// userId (``localUserId``) to the ``allUsers`` set.
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.localUserId = uid
        if self.role == .broadcaster {
            self.allUsers.insert(uid)
        }
    }

    /// The delegate is telling us that a remote user has joined the channel.
    ///
    /// - Parameters:
    /// - engine: The Agora RTC engine kit object.
    /// - uid: The ID of the user joining the channel.
    /// - elapsed: The time elapsed (ms) from the user calling `joinChannel` until this method is called.
    ///
    /// This method adds the remote user to the `allUsers` set.
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        self.allUsers.insert(uid)
    }

    /// The delegate is telling us that a remote user has left the channel.
    ///
    /// - Parameters:
    ///     - engine: The Agora RTC engine kit object.
    ///     - uid: The ID of the user who left the channel.
    ///     - reason: The reason why the user left the channel.
    ///
    /// This method removes the remote user from the `allUsers` set.
    open func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        self.allUsers.remove(uid)
    }
    
    func setVolume(for id: UInt, to isMuted: Bool) {
        if id == self.localUserId {
            self.agoraEngine.adjustRecordingSignalVolume(isMuted ? 100 : 0)
        } else {
            self.agoraEngine.adjustUserPlaybackSignalVolume(id, volume: Int32(isMuted ? 100 : 0))
        }
    }

    func setMic(for id: UInt, to isMuted: Bool)  {
        if id == self.localUserId {
            self.agoraEngine.muteLocalAudioStream(isMuted)
        }
    }
    
    func setAudio(eng: AgoraRtcEngineKit ) {
        // Audio Setup
        self.audioFrameDelegate = ModifyAudioFrameDelegate()
        eng.setAudioFrameDelegate(audioFrameDelegate)
        eng.setRecordingAudioFrameParametersWithSampleRate(
            16000, channel: 1, mode: .readWrite, samplesPerCall: 256
        )
        eng.setMixedAudioFrameParametersWithSampleRate(
            16000, channel: 1, samplesPerCall: 256
        )
        eng.setPlaybackAudioFrameParametersWithSampleRate(
            16000, channel: 1, mode: .readWrite, samplesPerCall: 256
        )
        eng.enableAudio()
    }
}
