//
//  ContentView.swift
//  Call Break Score Board
//
//  Created by Rohan Rathee on 10/01/25.
//


// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var players: [Player] = []
    @State private var isGameActive = false
    @State private var numberOfPlayers = 4

    var body: some View {
        NavigationStack { // Use NavigationStack
            VStack {
                Text("Call Break Score Board")
                    .font(.largeTitle)
                    .padding()

                Picker("Number of Players", selection: $numberOfPlayers) {
                    ForEach([3, 4], id: \.self) { num in
                        Text("\(num) Players")
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                PlayerSetupView(players: $players, numberOfPlayers: numberOfPlayers)

                if players.count == numberOfPlayers {
                    Button("Start Game") {
                        isGameActive = true
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationDestination(isPresented: $isGameActive) { // Correct navigation
                if players.count == numberOfPlayers {
                    GameView(game: Game(players: players, rounds: []))
                }
            }
            .navigationTitle("Call Break")
        }
    }
}
