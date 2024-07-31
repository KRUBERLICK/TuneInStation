//
//  StationPlaybackView.swift
//  TuneInStation
//
//  Created by Danylo Ilchyshyn on 30.07.2024.
//

import SwiftUI

struct StationPlaybackView<ViewModel: StationPlaybackViewModelType>: View {
    @StateObject var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        
        return VStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 20)
                    .padding(.bottom, 5)
            }
            ScrollView {
                VStack {
                    AsyncImage(url: viewModel.station.imgUrl, content: { img in
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
                    Text(viewModel.station.name)
                        .font(.title)
                        .fontWeight(.black)
                    Button {
                        viewModel.isPlaying.toggle()
                    } label: {
                        HStack {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(1 / 1, contentMode: .fit)
                                .frame(width: 40)
                            Text(viewModel.isPlaying ? "Pause" : "Play")
                                .font(.title)
                                .foregroundStyle(.gray)
                                .padding(.leading, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.gray)
                                    .opacity(0.2)
                            )
                    }
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    Text("About")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.top, 20)
                    Text(viewModel.station.description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.gray)
                                .opacity(0.2)
                        )
                    Text("Tags")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .padding(.top, 20)
                    Text(viewModel.station.tags.joined(separator: ", "))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.gray)
                                .opacity(0.2)
                        )
                    if let popularity = viewModel.station.popularity, let popularityString = numberFormatter.string(from: NSNumber(value: popularity)) {
                        Text("Popularity")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.top, 20)
                        Text(popularityString)
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.gray)
                                    .opacity(0.2)
                            )
                    }
                    if let reliability = viewModel.station.reliability {
                        Text("Reliability")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.top, 20)
                        Text("\(reliability)")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.gray)
                                    .opacity(0.2)
                            )
                    }
                    Spacer()
                }
            }
            .scrollIndicators(.never)
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
        .padding()
        .background(Color(hex: "0E1118"))
    }
}

#Preview {
    StationPlaybackView(viewModel: StationPlaybackViewModel(station: TuneInStation(description: "Test", name: "Test", imgUrl: nil, streamUrl: nil, reliability: 67, popularity: 3, tags: ["one", "two", "three"])))
        .preferredColorScheme(.dark)
}
