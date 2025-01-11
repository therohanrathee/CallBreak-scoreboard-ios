import SwiftUI

struct GameView: View {
    @Binding var game: Game
    @State private var calls: [UUID: String] = [:]
    @State private var made: [UUID: String] = [:]
    @State private var currentRoundNumber = 1
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    private let numberOfRounds = 5

    var body: some View {
        ScrollView {
            VStack {
                if currentRoundNumber <= numberOfRounds {
                    roundInputView
                } else {
                    gameOverView
                }
                roundHistoryView
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

    private var roundInputView: some View {
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
        }
    }

    private var gameOverView: some View {
        VStack(alignment: .leading) {
            Text("Game Over!")
                .font(.largeTitle)
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .center)

            ForEach(game.rounds.indices, id: \.self) { roundIndex in
                VStack(alignment: .leading) {
                    Text("Round \(roundIndex + 1) Scores:")
                        .font(.headline)
                    HStack {
                        ForEach(game.players) { player in
                            Text("\(player.name): \((Double(game.rounds[roundIndex].scores[player.id] ?? 0) / 10.0), specifier: "%.1f")")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    Divider()
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal)

            VStack(alignment: .leading) {
                Text("Final Standings:")
                    .font(.headline)
                    .padding(.bottom, 4)

                ForEach(rankedPlayers(), id: \.player.id) { playerWithRank in
                    HStack {
                        Text("\(playerWithRank.rank).")
                        Text(playerWithRank.player.name)
                        Spacer()
                        Text("Total Score: \((Double(playerWithRank.totalScore) / 10.0), specifier: "%.1f")")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)

            Button("Play Again") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var roundHistoryView: some View {
        List {
            ForEach(game.rounds.indices, id: \.self) { index in
                HStack {
                    Text("Round \(index + 1):")
                    ForEach(game.players) { player in
                        Text("\((Double(game.rounds[index].scores[player.id] ?? 0) / 10.0), specifier: "%.1f")")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .listStyle(.plain)
        .padding(.bottom)
    }

    func calculateTotalScore(for player: Player) -> Int {
        game.rounds.reduce(0) { total, round in
            total + (round.scores[player.id] ?? 0)
        }
    }

    func rankedPlayers() -> [(player: Player, totalScore: Int, rank: Int)] {
        var playersWithScores: [(player: Player, totalScore: Int)] = []
        for player in game.players {
            let totalScore = calculateTotalScore(for: player)
            playersWithScores.append((player, totalScore))
        }

        let sortedPlayers = playersWithScores.sorted { $0.totalScore > $1.totalScore }

        var rankedPlayers: [(player: Player, totalScore: Int, rank: Int)] = []
        var rank = 1
        for (index, playerWithScore) in sortedPlayers.enumerated() {
            if index > 0 && playerWithScore.totalScore < sortedPlayers[index - 1].totalScore {
                rank += 1
            }
            rankedPlayers.append((playerWithScore.player, playerWithScore.totalScore, rank))
        }
        return rankedPlayers
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

            var score = 0
            if game.isBlind {
                if made > call {
                    score = call * 20 + (made - call)
                } else if made == call {
                    score = call * 20
                } else {
                    score = -call * 20
                }
            } else {
                if made > call {
                    score = call * 10 + (made - call)
                } else if made == call {
                    score = call * 10
                } else {
                    score = -call * 10
                }
            }
            roundScores[player.id] = score
        }
        game.rounds.append(Round(scores: roundScores))
        calls = [:]
        made = [:]
        currentRoundNumber += 1
    }
}
