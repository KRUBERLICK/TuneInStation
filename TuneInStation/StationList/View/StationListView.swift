//
//  StationListView.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI

struct StationListView<ViewModel: StationListViewModelType>: View {
    @StateObject var viewModel: ViewModel
    
    @State private(set) var isLoadInProgress = false
    
    var body: some View {
        List {
            Section("Tags") {
                if isLoadInProgress {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    TagsView(allTags: viewModel.allTags, activeTags: $viewModel.activeTags)
                        .padding(.vertical, 5)
                }
            }
            Section("Stations") {
                Picker("Sorting", selection: $viewModel.stationSorting) {
                    ForEach(StationSorting.allCases, id: \.self) { sorting in
                        Text(sorting.rawValue).tag(sorting as StationSorting)
                    }
                }
                if isLoadInProgress {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 10),
                            GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 10)
                        ],
                        spacing: 20
                    ) {
                        ForEach(viewModel.stations) { station in
                            VStack(alignment: .leading) {
                                AsyncImage(url: station.imgUrl, content: { img in
                                    Group {
                                        if let image = img.image {
                                            image.resizable()
                                        } else {
                                            Rectangle()
                                                .fill(.gray)
                                        }
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                })
                                .aspectRatio(1 / 1, contentMode: .fill)
                                Text(station.name)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            .allowsHitTesting(true)
                            .gesture(
                                TapGesture()
                                    .onEnded {
                                        viewModel.activeStation = station
                                    }
                            )
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .alert(
            "Error",
            isPresented: .constant(viewModel.lastErrorMessage != nil),
            presenting: viewModel.lastErrorMessage,
            actions: { _ in
                Button("OK") {
                    viewModel.lastErrorMessage = nil
                }
            },
            message: { errorMessage in
            Text(errorMessage)
        })
        .task {
            isLoadInProgress = true
            defer {
                isLoadInProgress = false
            }
            await viewModel.fetchStations()
        }
        .sheet(item: $viewModel.activeStation) { station in
            StationPlaybackView(viewModel: StationPlaybackViewModel(station: station))
        }
        .scrollIndicators(.never)
        .background(Color(hex: "0E1118"))
        .navigationTitle("TuneIn Station")
    }
}

#Preview {
    NavigationStack {
        StationListView(viewModel: StationListViewModel(tuneInAPI: TuneInAPI()))
    }
    .preferredColorScheme(.dark)
}
