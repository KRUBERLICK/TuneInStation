//
//  TuneInAPI.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import Foundation

enum APIError: LocalizedError {
    case badResponse
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badResponse:
            return "Bad response from the server"
        case .unknown:
            return "Something went wrong"
        }
    }
}

struct FetchStationsAPIResponse: Codable {
    let data: [TuneInStation]
}

protocol TuneInAPIType {
    func fetchStations() async throws -> [TuneInStation]
}

final class TuneInAPI: TuneInAPIType {
    init() {
        urlSession = URLSession(configuration: .default)
    }
    
    func fetchStations() async throws -> [TuneInStation] {
        do {
            let (data, response) = try await urlSession.data(from: apiURL)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.badResponse
            }
            
            let apiResponse = try decoder.decode(FetchStationsAPIResponse.self, from: data)
            
            return apiResponse.data
        } catch {
            if error is DecodingError {
                throw APIError.badResponse
            } else {
                throw APIError.unknown
            }
        }
    }
    
    private let urlSession: URLSession
    private let apiURL = URL(string: "https://s3-us-west-1.amazonaws.com/cdn-web.tunein.com/stations.json")!
    private let decoder = JSONDecoder()
}
