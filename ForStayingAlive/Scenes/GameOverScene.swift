//
//  GameOverScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 15/06/24.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene{
    private let gameOverLabel = LabelNode(text: "Game Over", fontSize: 48, fontColor: .red)
    
    override func sceneDidLoad() {
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        addChild(gameOverLabel)
    }
}
