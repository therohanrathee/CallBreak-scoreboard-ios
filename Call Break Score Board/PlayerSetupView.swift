//
//  PlayerSetupView.swift
//  Call Break Score Board
//
//  Created by Rohan Rathee on 10/01/25.
//


// PlayerSetupView.swift
import SwiftUI

struct PlayerSetupView: View {
    @Binding var players: [Player]
    let numberOfPlayers: Int
    @State private var newPlayerName: String = ""
    @FocusState private var nameIsFocused: Bool

    var body: some View {
        VStack {
            TextField("Player Name", text: $newPlayerName)
                .textFieldStyle(.roundedBorder)
                .padding()
                .focused($nameIsFocused)
                .onSubmit {
                    addPlayer()
                }
            Button("Add Player") {
                addPlayer()
            }
            .padding(.bottom)
            .disabled(newPlayerName.isEmpty || players.count >= numberOfPlayers)

            List {
                ForEach(players) { player in
                    Text(player.name)
                }
                .onDelete(perform: deletePlayers)
            }
            .listStyle(.plain) // Cleaner list style
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if players.count < numberOfPlayers {
                    self.nameIsFocused = true
                }
            }
        }
    }

    func addPlayer() {
        if !newPlayerName.isEmpty && players.count < numberOfPlayers {
            players.append(Player(name: newPlayerName))
            newPlayerName = ""
        }
    }

    func deletePlayers(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}
