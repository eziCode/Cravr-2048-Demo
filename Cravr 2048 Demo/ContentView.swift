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

// Tile view component with animations
struct TileView: View {
    let value: Int
    @State private var isAppearing = false
    @State private var isCombining = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor)
                .frame(width: 70, height: 70)
                .shadow(color: tileColor.opacity(0.3), radius: isCombining ? 8 : 4, x: 0, y: 2)
                .scaleEffect(isAppearing ? 1.0 : 0.1)
                .scaleEffect(isCombining ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAppearing)
                .animation(.easeInOut(duration: 0.2), value: isCombining)
            
            if value > 0 {
                Text("\(value)")
                    .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                    .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    .scaleEffect(isCombining ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isCombining)
            }
        }
        .onAppear {
            if value > 0 {
                withAnimation {
                    isAppearing = true
                }
            }
        }
        .onChange(of: value) { oldValue, newValue in
            if newValue > oldValue && oldValue > 0 {
                // Tile is combining
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCombining = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCombining = false
                    }
                }
            } else if newValue > 0 && oldValue == 0 {
                // New tile appearing
                isAppearing = false
                withAnimation {
                    isAppearing = true
                }
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

struct ContentView: View {
    @StateObject private var game = Game2048()
    @State private var animationOffset = CGSize.zero
    @State private var isAnimating = false
    
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
                .scaleEffect(isAnimating ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isAnimating)
                .offset(animationOffset)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: animationOffset)
                
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
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onChanged { gesture in
                    // Start swipe animation
                    if !isAnimating {
                        withAnimation(.easeOut(duration: 0.1)) {
                            isAnimating = true
                        }
                        
                        // Slight visual feedback during drag
                        let scale: CGFloat = 0.98
                        animationOffset = CGSize(
                            width: gesture.translation.width * 0.02,
                            height: gesture.translation.height * 0.02
                        )
                    }
                }
                .onEnded { gesture in
                    let horizontal = gesture.translation.width
                    let vertical = gesture.translation.height
                    
                    // Reset animation state
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isAnimating = false
                        animationOffset = .zero
                    }
                    
                    // Determine direction and move
                    let direction: Direction
                    if abs(horizontal) > abs(vertical) {
                        direction = horizontal < 0 ? .left : .right
                    } else {
                        direction = vertical < 0 ? .up : .down
                    }
                    
                    // Play haptic and sound feedback
                    Haptics.shared.impact(.light)
                    SoundManager.shared.playSwoosh()
                    
                    // Perform move with animation
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        game.move(direction)
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
    
    init() {
        // Initialize the game
    }
    
    func startGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
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
            
            // Play sound for new tile
            SoundManager.shared.playBubble()
        }
    }
    
    func move(_ direction: Direction) {
        let oldGrid = grid
        var moved = false
        var combined = false
        
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
        
        if moved { 
            addRandomTile()
            
            // Play different sounds based on action
            if combined {
                Haptics.shared.impact(.medium)
                SoundManager.shared.playChime()
            } else {
                Haptics.shared.microHaptic()
                SoundManager.shared.playPop()
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
}

#Preview {
    ContentView()
}
