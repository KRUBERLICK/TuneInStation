//
//  TuneInAPIMock.swift
//  TuneInStationTests
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import Foundation

final class TuneInAPIMock: TuneInAPIType {
    enum MockResponseType {
        case normal
        case error
        case empty
    }
    
    var responseType: MockResponseType = .normal
    
    func fetchStations() async throws -> [TuneInStation] {
        try! await Task.sleep(for: .seconds(1))
        
        switch responseType {
        case .normal:
            guard let mockFileURL = Bundle.main.url(forResource: "APIResponseMock", withExtension: "json"),
                  let data = try? Data(contentsOf: mockFileURL) else {
                fatalError()
            }
            let apiResponse = try! JSONDecoder().decode(FetchStationsAPIResponse.self, from: data)
            return apiResponse.data
        case .error:
            throw APIError.badResponse
        case .empty:
            return []
        }
    }
}


