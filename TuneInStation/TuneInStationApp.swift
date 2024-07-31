//
//  TuneInStationApp.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI

@main
struct TuneInStationApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StationListView(viewModel: StationListViewModel(tuneInAPI: TuneInAPI()))
            }
            .preferredColorScheme(.dark)
        }
    }
}
