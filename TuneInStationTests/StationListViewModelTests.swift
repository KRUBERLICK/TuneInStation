//
//  TuneInStationTests.swift
//  TuneInStationTests
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import XCTest
@testable import TuneInStation

final class TuneInStationTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testStationsFetchWithNormalResponse() async {
        let apiMock = TuneInAPIMock()
        apiMock.responseType = .normal
        let stationListViewModel = StationListViewModel(tuneInAPI: apiMock)
        
        await stationListViewModel.fetchStations()
        assert(stationListViewModel.stations.count == 10)
    }
    
    @MainActor func testStationsFetchWithError() async {
        let apiMock = TuneInAPIMock()
        apiMock.responseType = .error
        let stationListViewModel = StationListViewModel(tuneInAPI: apiMock)
        
        await stationListViewModel.fetchStations()
        assert(stationListViewModel.stations.isEmpty)
        assert(stationListViewModel.lastErrorMessage == "Bad response from the server")
    }
    
    @MainActor func testStationsFetchWithEmptyResponse() async {
        let apiMock = TuneInAPIMock()
        apiMock.responseType = .empty
        let stationListViewModel = StationListViewModel(tuneInAPI: apiMock)
        
        await stationListViewModel.fetchStations()
        assert(stationListViewModel.stations.isEmpty)
        assert(stationListViewModel.lastErrorMessage == nil)
    }
    
    @MainActor func testStationTagsFiltering() async {
        let apiMock = TuneInAPIMock()
        apiMock.responseType = .normal
        let stationListViewModel = StationListViewModel(tuneInAPI: apiMock)
        
        await stationListViewModel.fetchStations()
        assert(stationListViewModel.stations.count == 10)
        assert(stationListViewModel.allTags == ["404", "classical", "hits", "holiday music", "local news", "music", "news", "pop & dance", "sports", "talk", "world news"])
        assert(stationListViewModel.activeTags.isEmpty)
        
        stationListViewModel.activeTags = ["404"]
        assert(stationListViewModel.stations.count == 1)
        assert(stationListViewModel.stations[0].name == "404 Station")
        
        stationListViewModel.activeTags = []
        assert(stationListViewModel.stations.count == 10)
    }
    
    @MainActor func testStationSorting() async {
        let apiMock = TuneInAPIMock()
        apiMock.responseType = .normal
        let stationListViewModel = StationListViewModel(tuneInAPI: apiMock)
        
        await stationListViewModel.fetchStations()
        assert(stationListViewModel.stations.count == 10)
        assert(stationListViewModel.stationSorting == .default)
        assert(stationListViewModel.stations[0].name == "Radio Mozart")
        
        stationListViewModel.stationSorting = .popularity
        assert(stationListViewModel.stations[0].name == "Radio Santa Claus")
        
        stationListViewModel.stationSorting = .reliability
        assert(stationListViewModel.stations[0].name == "talkSPORT")
        
        stationListViewModel.stationSorting = .default
        assert(stationListViewModel.stations[0].name == "Radio Mozart")
    }
}
