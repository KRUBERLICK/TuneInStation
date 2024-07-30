//
//  StationListViewModel.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI
import Combine

enum StationSorting: String, CaseIterable {
    case `default`
    case popularity
    case reliability
    
    var rawValue: String {
        switch self {
        case .default:
            return "Default"
        case .popularity:
            return "Popularity"
        case .reliability:
            return "Reliability"
        }
    }
}

@MainActor protocol StationListViewModelType: ObservableObject {
    var allTags: [String] { get }
    var activeTags: Set<String> { get set }
    var stations: [TuneInStation] { get }
    var stationSorting: StationSorting { get set }
    var activeStation: TuneInStation? { get set }
    var lastErrorMessage: String? { get set }
    
    func fetchStations() async
}

class StationListViewModel: StationListViewModelType {
    @Published private(set) var allTags: [String] = []
    @Published var activeTags: Set<String> = []
    
    @Published private(set) var stations: [TuneInStation] = []
    @Published var stationSorting: StationSorting = .default
    @Published var activeStation: TuneInStation?
    
    @Published var lastErrorMessage: String?
    
    init(tuneInAPI: TuneInAPIType) {
        self.tuneInAPI = tuneInAPI
        
        $activeTags
            .dropFirst()
            .sink { [unowned self] tags in
                self.filterStations(tags: tags, sorting: self.stationSorting)
            }
            .store(in: &subscriptions)
        
        $stationSorting
            .dropFirst()
            .sink { [unowned self] sorting in
                self.filterStations(tags: self.activeTags, sorting: sorting)
            }
            .store(in: &subscriptions)
    }
    
    // fetches the stations list from the api
    func fetchStations() async {
        do {
            allStations = try await tuneInAPI.fetchStations()
            allTags = Array(Set(allStations.flatMap { $0.tags })).sorted()
            activeTags = []
            stations = allStations
        } catch {
            if let apiError = error as? APIError {
                lastErrorMessage = apiError.errorDescription
            }
        }
    }
    
    private let tuneInAPI: TuneInAPIType
    private var allStations: [TuneInStation] = []
    private var subscriptions = Set<AnyCancellable>()
    
    // filter stations by active tags
    private func filterStations(tags: Set<String>, sorting: StationSorting) {
        stations = sortedStations(allStations, sorting: sorting)
        
        guard !tags.isEmpty else {
            return
        }
        
        stations = stations.filter { $0.tags.filter { tags.contains($0) }.count > 0 }
    }
    
    private func sortedStations(_ stations: [TuneInStation], sorting: StationSorting) -> [TuneInStation] {
        switch sorting {
        case .popularity:
            return stations.sorted(by: {
                let pop1 = $0.popularity ?? 0
                let pop2 = $1.popularity ?? 0
                return pop1 > pop2
            })
        case .reliability:
            return stations.sorted(by: {
                let rel1 = $0.reliability ?? 0
                let rel2 = $1.reliability ?? 0
                return rel1 > rel2
            })
        default:
            return stations
        }
    }
}
