//
//  EvacuationScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 14/06/24.
//

import Foundation
import GameplayKit

class EvacuationScene: SKScene{
    private let gameOverLabel = LabelNode(text: "Game Over", fontSize: 48, fontColor: .blue)
    
    override func sceneDidLoad() {
        gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        addChild(gameOverLabel)
    }
}
