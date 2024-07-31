//
//  StationPlaybackViewModel.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI
import Combine
import AVKit

@MainActor protocol StationPlaybackViewModelType: ObservableObject {
    var station: TuneInStation { get }
    var isPlaying: Bool { get set }
    var lastErrorMessage: String? { get set }
}

final class StationPlaybackViewModel: StationPlaybackViewModelType {
    @Published private(set) var station: TuneInStation
    @Published var isPlaying: Bool = true
    
    @Published var lastErrorMessage: String?
    
    init(station: TuneInStation) {
        self.station = station
        
        $isPlaying
            .dropFirst()
            .sink { [unowned self] _ in
                if self.isPlaying {
                    self.avPlayer?.pause()
                } else {
                    self.avPlayer?.play()
                }
            }
            .store(in: &subscriptions)
        
        NotificationCenter
            .default
            .publisher(for: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let strongSelf = self else {
                    return
                }
                
                guard let userInfo = notification.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
                }
                
                switch type {
                case .began:
                    strongSelf.avPlayer?.pause()
                case .ended:
                    strongSelf.avPlayer?.play()
                default:
                    break
                }
            }
            .store(in: &subscriptions)
        
        self.initPlayer()
    }
    
    deinit {
        avPlayer?.pause()
        avPlayer = nil
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var avPlayer: AVPlayer?
    
    private func initPlayer() {
        guard avPlayer == nil else {
            return
        }
        
        guard let streamURL = station.streamUrl else {
            lastErrorMessage = "Cannot play the station"
            return
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            lastErrorMessage = "Failed to configure audio playback"
            return
        }
        
        avPlayer = AVPlayer(url: streamURL)
        avPlayer?.play()
    }
}
