//
//  GameView.swift
//  Call Break Score Board
//
//  Created by Rohan Rathee on 10/01/25.
//


// GameView.swift
import SwiftUI

struct GameView: View {
    @State var game: Game
    @State private var round: Round = Round(scores: [:]) // Current round data
    @State private var calls: [UUID: String] = [:]
    @State private var made: [UUID: String] = [:]
    @State private var currentRoundNumber = 1
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView { // Added ScrollView
            VStack {
                Text("Round \(currentRoundNumber)")
                    .font(.title2)
                    .padding(.top)

                ForEach(game.players) { player in
                    VStack {
                        Text(player.name)
                            .font(.headline)

                        HStack {
                            Text("Call:")
                            TextField("Call", text: Binding(
                                get: { calls[player.id, default: ""] },
                                set: { calls[player.id] = $0.filter { "0123456789".contains($0) } }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.center)

                            Text("Made:")
                            TextField("Made", text: Binding(
                                get: { made[player.id, default: ""] },
                                set: { made[player.id] = $0.filter { "0123456789".contains($0) } }
                            ))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }

                Button("End Round") {
                    calculateScores()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(calls.count != game.players.count || made.count != game.players.count)

                List {
                    ForEach(game.rounds.indices, id: \.self) { index in
                        HStack {
                            Text("Round \(index + 1):")
                            ForEach(game.players) { player in
                                Text("\(game.rounds[index].scores[player.id] ?? 0)")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding(.bottom)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
        .navigationTitle("Game")
    }

    func calculateScores() {
        let totalCall = game.players.reduce(0) { sum, player in
            sum + (Int(calls[player.id] ?? "0") ?? 0)
        }
        let totalMade = game.players.reduce(0) { sum, player in
            sum + (Int(made[player.id] ?? "0") ?? 0)
        }
        let targetMade = game.players.count == 4 ? 13 : 17
        let minCall = game.players.count == 4 ? 9 : 13
        if totalCall < minCall {
            alertMessage = "Total call must be at least \(minCall). Reshuffle cards."
            showAlert = true
            return
        }
        if totalMade != targetMade {
            alertMessage = "Total made must be exactly \(targetMade)."
            showAlert = true
            return
        }

        var roundScores: [UUID: Int] = [:]
        for player in game.players {
            let call = Int(calls[player.id] ?? "0") ?? 0
            let made = Int(made[player.id] ?? "0") ?? 0
            let score = made > call ? call + (made - call)/10 : -call
            roundScores[player.id] = score
        }
        game.rounds.append(Round(scores: roundScores))
        calls = [:]
        made = [:]
        currentRoundNumber += 1
    }
}
