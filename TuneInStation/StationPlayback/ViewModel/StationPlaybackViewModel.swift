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
        
        avPlayer = AVPlayer(url: streamURL)
        avPlayer?.play()
    }
}
