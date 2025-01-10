//
//  Models.swift
//  Call Break Score Board
//
//  Created by Rohan Rathee on 10/01/25.
//


// Models.swift (Separate file for data models)
import Foundation

struct Player: Identifiable, Hashable { // Make Player Hashable
    let id = UUID()
    var name: String
    var score: Int = 0
}

struct Game: Identifiable {
    let id = UUID()
    var players: [Player]
    var rounds: [Round]
}

struct Round: Identifiable {
    let id = UUID()
    var scores: [UUID: Int]
}
