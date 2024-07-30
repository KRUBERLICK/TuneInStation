//
//  TuneInStation.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import Foundation

struct TuneInStation: Identifiable, Codable {
    let id: String = UUID().uuidString
    let description: String
    let name: String
    let imgUrl: URL?
    let streamUrl: URL?
    let reliability: Int?
    let popularity: Double?
    let tags: [String]
    
    private enum CodingKeys: String, CodingKey {
        case description, name, imgUrl, streamUrl, reliability, popularity, tags
    }
}
