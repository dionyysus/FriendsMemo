//
//  Friend.swift
//  FriendsMemo
//
//  Created by Gizem Coskun on 27/02/25.
//

import SwiftUI

struct Friend: Identifiable, Codable {
    let id = UUID()
    let name: String
    let emoji: String
    private var colorName: String 

    var color: Color {
        switch colorName {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        default: return .gray
        }
    }

    init(name: String, color: Color, emoji: String) {
        self.name = name
        self.emoji = emoji
        self.colorName = Friend.getColorName(color)
    }

    private static func getColorName(_ color: Color) -> String {
        if color == .blue { return "blue" }
        if color == .red { return "red" }
        if color == .green { return "green" }
        if color == .yellow { return "yellow" }
        return "gray"
    }
}
