import Foundation

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var score: Int = 0
}

struct Game: Identifiable {
    let id = UUID()
    var players: [Player]
    var rounds: [Round]
    let isBlind: Bool // Add isBlind property
}

struct Round: Identifiable {
    let id = UUID()
    var scores: [UUID: Int]
}
