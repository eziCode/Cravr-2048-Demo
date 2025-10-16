//
//  ContentView.swift
//  Cravr 2048 Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    @StateObject private var game = Game2048()
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { col in
                        let value = game.grid[row][col]
                        Text(value == 0 ? "" : "\(value)")
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.3))
                            .font(.title)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { gesture in
                    let horizontal = gesture.translation.width
                    let vertical = gesture.translation.height
                    if abs(horizontal) > abs(vertical) {
                        if horizontal < 0 {
                            game.move(Direction.left)
                        } else {
                            game.move(Direction.right)
                        }
                    } else {
                        if vertical < 0 {
                            game.move(Direction.up)
                        } else {
                            game.move(Direction.down)
                        }
                    }
                }
        )
        .onAppear {
            game.startGame()
        }
    }
}

enum Direction {
    case up, down, left, right
}

class Game2048: ObservableObject {
    
    @Published var grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    
    init() {
        // Initialize the game
    }
    
    func startGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        addRandomTile()
        addRandomTile()
    }
    
    func addRandomTile() {
        let empty = grid.enumerated().flatMap { r, row in
            row.enumerated().compactMap { c, value in
                value == 0 ? (r, c) : nil
            }
        }
        if let spot = empty.randomElement() {
            grid[spot.0][spot.1] = Bool.random() ? 2 : 4
        }
    }
    
    func move(_ direction: Direction) {
        var moved = false
        switch direction {
        case .left:
            for i in 0..<4 {
                let (newRow, changed) = merge(row: grid[i])
                grid[i] = newRow
                if changed { moved = true }
            }
        case .right:
            for i in 0..<4 {
                let reversed = Array(grid[i].reversed())
                let (newRow, changed) = merge(row: reversed)
                grid[i] = Array(newRow.reversed())
                if changed { moved = true }
            }
        case .up:
            for i in 0..<4 {
                let column = (0..<4).map { grid[$0][i] }
                let (newCol, changed) = merge(row: column)
                for j in 0..<4 { grid[j][i] = newCol[j] }
                if changed { moved = true }
            }
        case .down:
            for i in 0..<4 {
                let column = (0..<4).map { grid[$0][i] }.reversed()
                let (newCol, changed) = merge(row: Array(column))
                for j in 0..<4 { grid[j][i] = newCol.reversed()[j] }
                if changed { moved = true }
            }
        }
        
        if moved { addRandomTile() }
    }
    
    private func merge(row: [Int]) -> ([Int], Bool) {
        var newRow = row.filter { $0 != 0 }
        var changed = false
        var i = 0
        while i < newRow.count - 1 {
            if newRow[i] == newRow[i+1] {
                newRow[i] *= 2
                newRow.remove(at: i+1)
                changed = true
            }
            i += 1
        }
        while newRow.count < 4 { newRow.append(0) }
        if newRow != row { changed = true }
        return (newRow, changed)
    }
}



#Preview {
    ContentView()
}
