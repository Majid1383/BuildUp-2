//
//  Levels.swift
//  BuildUp
//
//  Created by AbdulMajid Shaikh on 10/09/24.
//

import Foundation

struct GameLevel{
    let levelNumber : Int
    let nodeSize : CGSize
}

struct LevelManager {
    let levels: [GameLevel]

    init() {
        self.levels = [
            GameLevel(levelNumber: 1, nodeSize: BoxSize.square(100).size),    // Easy square
            GameLevel(levelNumber: 2, nodeSize: BoxSize.square(90).size),     // Slightly smaller square
            GameLevel(levelNumber: 3, nodeSize: BoxSize.rectangle(80, 40).size), // Easy rectangle
            GameLevel(levelNumber: 4, nodeSize: BoxSize.square(80).size),     // Square
            GameLevel(levelNumber: 5, nodeSize: BoxSize.rectangle(70, 35).size), // Rectangle
            GameLevel(levelNumber: 6, nodeSize: BoxSize.square(75).size),     // Smaller square
            GameLevel(levelNumber: 7, nodeSize: BoxSize.rectangle(60, 30).size), // Rectangle
            GameLevel(levelNumber: 8, nodeSize: BoxSize.square(70).size),     // Square
            GameLevel(levelNumber: 9, nodeSize: BoxSize.rectangle(65, 25).size), // Rectangle
            GameLevel(levelNumber: 10, nodeSize: BoxSize.square(65).size),    // Smaller square
            GameLevel(levelNumber: 11, nodeSize: BoxSize.rectangle(60, 20).size), // Rectangle
            GameLevel(levelNumber: 12, nodeSize: BoxSize.square(60).size),    // Square
            GameLevel(levelNumber: 13, nodeSize: BoxSize.rectangle(55, 15).size), // Rectangle
            GameLevel(levelNumber: 14, nodeSize: BoxSize.square(55).size),    // Smaller square
            GameLevel(levelNumber: 15, nodeSize: BoxSize.rectangle(50, 25).size), // Rectangle
            GameLevel(levelNumber: 16, nodeSize: BoxSize.square(50).size),    // Square
            GameLevel(levelNumber: 17, nodeSize: BoxSize.rectangle(45, 20).size), // Rectangle
            GameLevel(levelNumber: 18, nodeSize: BoxSize.square(45).size),    // Smaller square
            GameLevel(levelNumber: 19, nodeSize: BoxSize.rectangle(40, 30).size), // Rectangle
            GameLevel(levelNumber: 20, nodeSize: BoxSize.square(40).size),    // Square
            GameLevel(levelNumber: 21, nodeSize: BoxSize.rectangle(35, 25).size), // Rectangle
            GameLevel(levelNumber: 22, nodeSize: BoxSize.square(35).size),    // Smaller square
            GameLevel(levelNumber: 23, nodeSize: BoxSize.rectangle(30, 15).size), // Rectangle
            GameLevel(levelNumber: 24, nodeSize: BoxSize.square(30).size),    // Square
            GameLevel(levelNumber: 25, nodeSize: BoxSize.rectangle(25, 20).size), // Rectangle
            GameLevel(levelNumber: 26, nodeSize: BoxSize.square(25).size),    // Smaller square
            GameLevel(levelNumber: 27, nodeSize: BoxSize.rectangle(20, 10).size), // Rectangle
            GameLevel(levelNumber: 28, nodeSize: BoxSize.square(20).size),    // Square
            GameLevel(levelNumber: 29, nodeSize: BoxSize.rectangle(15, 10).size), // Rectangle
            GameLevel(levelNumber: 30, nodeSize: BoxSize.square(15).size),    // Smaller square
            GameLevel(levelNumber: 31, nodeSize: BoxSize.rectangle(10, 5).size), // Rectangle
            GameLevel(levelNumber: 32, nodeSize: BoxSize.square(10).size),    // Square
            GameLevel(levelNumber: 33, nodeSize: BoxSize.rectangle(8, 4).size),  // Rectangle
            GameLevel(levelNumber: 34, nodeSize: BoxSize.square(8).size),      // Smaller square
            GameLevel(levelNumber: 35, nodeSize: BoxSize.rectangle(6, 3).size),  // Rectangle
            GameLevel(levelNumber: 36, nodeSize: BoxSize.square(6).size),      // Square
            GameLevel(levelNumber: 37, nodeSize: BoxSize.rectangle(5, 2).size),  // Rectangle
            GameLevel(levelNumber: 38, nodeSize: BoxSize.square(5).size),      // Smaller square
            GameLevel(levelNumber: 39, nodeSize: BoxSize.rectangle(4, 2).size),  // Rectangle
            GameLevel(levelNumber: 40, nodeSize: BoxSize.square(4).size),      // Square
            GameLevel(levelNumber: 41, nodeSize: BoxSize.rectangle(3, 1.5).size), // Rectangle
            GameLevel(levelNumber: 42, nodeSize: BoxSize.square(3).size),      // Smaller square
            GameLevel(levelNumber: 43, nodeSize: BoxSize.rectangle(2, 1).size),  // Rectangle
            GameLevel(levelNumber: 44, nodeSize: BoxSize.square(2).size),      // Square
            GameLevel(levelNumber: 45, nodeSize: BoxSize.rectangle(1.5, 1).size), // Rectangle
            GameLevel(levelNumber: 46, nodeSize: BoxSize.square(1.5).size),    // Smaller square
            GameLevel(levelNumber: 47, nodeSize: BoxSize.rectangle(1, 0.5).size), // Rectangle
            GameLevel(levelNumber: 48, nodeSize: BoxSize.square(1).size),      // Smallest square
            GameLevel(levelNumber: 49, nodeSize: BoxSize.rectangle(0.8, 0.4).size), // Rectangle
            GameLevel(levelNumber: 50, nodeSize: BoxSize.square(0.5).size)     // Smallest square
        ]
    }
}

