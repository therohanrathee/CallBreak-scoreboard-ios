import SwiftUI

struct ContentView: View {
    @State private var players: [Player] = []
    @State private var isGameActive = false
    @State private var numberOfPlayers = 4
    @State private var game: Game?
    @State private var isBlindCall = false

    var body: some View {
        NavigationStack {
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

                Spacer()
                    .frame(height: 20)

                Toggle("Blind Call", isOn: $isBlindCall)
                    .padding(.horizontal)

                PlayerSetupView(players: $players, numberOfPlayers: numberOfPlayers)

                if players.count == numberOfPlayers {
                    Button(action: {
                        game = Game(players: players, rounds: [], isBlind: isBlindCall)
                        isGameActive = true
                    }) {
                        Text("Start Game")
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationDestination(isPresented: $isGameActive) {
                if let game = game {
                    let gameBinding = Binding { game } set: { self.game = $0 }
                    GameView(game: gameBinding)
                }
            }
            
        }
    }
}
