//
//  ContentView.swift
//  Cravr 2048 Demo
//
//  Created by Ezra Akresh on 10/16/25.
//

import SwiftUI
internal import Combine

// Color scheme for the game
struct GameColors {
    static let sgbusGreen = Color(hex: "1cd91f")
    static let nonPhotoBlue = Color(hex: "92dce5")
    static let maize = Color(hex: "f7ec59")
    static let pumpkin = Color(hex: "fa7921")
    static let darkSpace = Color(hex: "0a0a0a")
    static let tileBackground = Color.black.opacity(0.3)
}

// Simple tile view component
struct TileView: View {
    let value: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
                .frame(width: 70, height: 70)
                .shadow(color: tileColor.opacity(0.3), radius: 4, x: 0, y: 2)
            
            if value > 0 {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
            }
        }
    }
    
    private var tileColor: Color {
        switch value {
        case 0: return GameColors.tileBackground
        case 2: return GameColors.nonPhotoBlue.opacity(0.8)
        case 4: return GameColors.nonPhotoBlue
        case 8: return GameColors.maize.opacity(0.8)
        case 16: return GameColors.maize
        case 32: return GameColors.pumpkin.opacity(0.8)
        case 64: return GameColors.pumpkin
        case 128: return GameColors.sgbusGreen.opacity(0.8)
        case 256: return GameColors.sgbusGreen
        case 512: return GameColors.sgbusGreen
        case 1024: return GameColors.sgbusGreen
        case 2048: return GameColors.sgbusGreen
        default: return GameColors.sgbusGreen
        }
    }
    
    private var textColor: Color {
        switch value {
        case 2, 4: return GameColors.darkSpace
        case 8, 16: return GameColors.darkSpace
        case 32, 64: return .white
        default: return .white
        }
    }
    
    private var fontSize: CGFloat {
        switch value {
        case 0: return 0
        case 2...4: return 24
        case 8...16: return 22
        case 32...64: return 20
        case 128...256: return 18
        case 512...1024: return 16
        default: return 14
        }
    }
}

// Game over screen
struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
            
            Text("Final Score: \(score)")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
            
            Button("Play Again") {
                onRestart()
                Haptics.shared.impact(.medium)
                SoundManager.shared.playClick()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(GameColors.pumpkin.opacity(0.8))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.7))
                .blur(radius: 10)
        )
        .padding()
    }
}

struct ContentView: View {
    @StateObject private var game = Game2048()
    @State private var animationOffset = CGSize.zero
    @State private var isAnimating = false
    @State private var isMoving = false
    
    var body: some View {
        ZStack {
            // Star background
            StarBackground(starCount: 80, minStarSize: 1, maxStarSize: 2.5, opacity: 0.6)
            
            VStack(spacing: 20) {
                // Title
                Text("2048")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                
                // Game grid
                VStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { row in
                        HStack(spacing: 6) {
                            ForEach(0..<4, id: \.self) { col in
                                let value = game.grid[row][col]
                                TileView(value: value)
                            }
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.2))
                        .padding(-3)
                )
                .offset(animationOffset)
                .animation(.linear(duration: 0.2), value: animationOffset)
                
                // Score display
                HStack {
                    VStack {
                        Text("SCORE")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(game.score)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.3))
                    )
                    
                    Spacer()
                    
                    Button("New Game") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            game.startGame()
                        }
                        Haptics.shared.impact(.medium)
                        SoundManager.shared.playClick()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(GameColors.pumpkin.opacity(0.8))
                    )
                }
                .padding(.horizontal)
            }
            .padding()
            
            // Game over overlay
            if game.isGameOver {
                GameOverView(score: game.score) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        game.startGame()
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onChanged { gesture in
                    if !game.isGameOver && !isMoving {
                        // Simple visual feedback during drag
                        animationOffset = CGSize(
                            width: gesture.translation.width * 0.02,
                            height: gesture.translation.height * 0.02
                        )
                    }
                }
                .onEnded { gesture in
                    guard !game.isGameOver && !isMoving else { return }
                    
                    let horizontal = gesture.translation.width
                    let vertical = gesture.translation.height
                    
                    // Determine direction and move
                    let direction: Direction
                    if abs(horizontal) > abs(vertical) {
                        direction = horizontal < 0 ? .left : .right
                    } else {
                        direction = vertical < 0 ? .up : .down
                    }
                    
                    // Play haptic feedback
                    Haptics.shared.impact(.light)
                    
                    // Start move animation
                    isMoving = true
                    
                    // Reset animation state immediately
                    withAnimation(.linear(duration: 0.1)) {
                        animationOffset = .zero
                    }
                    
                    // Perform move immediately
                    game.move(direction)
                    
                    // End move animation quickly
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        isMoving = false
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
    @Published var score = 0
    @Published var isGameOver = false
    
    init() {
        // Initialize the game
    }
    
    func startGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        isGameOver = false
        addRandomTile()
        addRandomTile()
        SoundManager.shared.stopAllSounds()
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
        let oldGrid = grid
        var moved = false
        var combined = false
        
        // Move and merge tiles with linear animation
        withAnimation(.linear(duration: 0.15)) {
            switch direction {
            case .left:
                for i in 0..<4 {
                    let (newRow, changed, points) = merge(row: grid[i])
                    grid[i] = newRow
                    if changed { moved = true }
                    if points > 0 { 
                        combined = true
                        score += points
                    }
                }
            case .right:
                for i in 0..<4 {
                    let reversed = Array(grid[i].reversed())
                    let (newRow, changed, points) = merge(row: reversed)
                    grid[i] = Array(newRow.reversed())
                    if changed { moved = true }
                    if points > 0 { 
                        combined = true
                        score += points
                    }
                }
            case .up:
                for i in 0..<4 {
                    let column = (0..<4).map { grid[$0][i] }
                    let (newCol, changed, points) = merge(row: column)
                    for j in 0..<4 { grid[j][i] = newCol[j] }
                    if changed { moved = true }
                    if points > 0 { 
                        combined = true
                        score += points
                    }
                }
            case .down:
                for i in 0..<4 {
                    let column = (0..<4).map { grid[$0][i] }.reversed()
                    let (newCol, changed, points) = merge(row: Array(column))
                    for j in 0..<4 { grid[j][i] = newCol.reversed()[j] }
                    if changed { moved = true }
                    if points > 0 { 
                        combined = true
                        score += points
                    }
                }
            }
        }
        
        if moved { 
            // Add new tile immediately after move
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.linear(duration: 0.1)) {
                    self.addRandomTile()
                }
                
                // Only play sound when blocks merge
                if combined {
                    Haptics.shared.impact(.medium)
                    SoundManager.shared.playChime()
                }
                
                // Check for game over
                self.checkGameOver()
            }
        }
    }
    
    private func merge(row: [Int]) -> ([Int], Bool, Int) {
        var newRow = row.filter { $0 != 0 }
        var changed = false
        var points = 0
        var i = 0
        while i < newRow.count - 1 {
            if newRow[i] == newRow[i+1] {
                newRow[i] *= 2
                points += newRow[i]
                newRow.remove(at: i+1)
                changed = true
            }
            i += 1
        }
        while newRow.count < 4 { newRow.append(0) }
        if newRow != row { changed = true }
        return (newRow, changed, points)
    }
    
    private func checkGameOver() {
        // Check if there are any empty cells
        let hasEmpty = grid.flatMap { $0 }.contains(0)
        if hasEmpty {
            return
        }
        
        // Check if any moves are possible (adjacent cells with same values)
        for row in 0..<4 {
            for col in 0..<4 {
                let currentValue = grid[row][col]
                
                // Check right neighbor
                if col < 3 && grid[row][col + 1] == currentValue {
                    return
                }
                
                // Check bottom neighbor
                if row < 3 && grid[row + 1][col] == currentValue {
                    return
                }
            }
        }
        
        // No moves possible - game over
        isGameOver = true
        SoundManager.shared.stopAllSounds()
    }
}

#Preview {
    ContentView()
}
