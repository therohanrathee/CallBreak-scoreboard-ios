import Foundation

struct Player: Identifiable, Hashable {
    let id: UUID = UUID()
    var name: String
    var score: Int = 0
}

struct Game: Identifiable {
    let id: UUID = UUID()
    var players: [Player]
    var rounds: [Round]
}

struct Round: Identifiable {
    let id: UUID = UUID()
    var scores: [UUID: Int]
    var isBlind: Bool
    var calls: [UUID: Int]
    var made: [UUID: Int]
}
