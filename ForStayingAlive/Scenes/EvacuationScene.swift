//
//  EvacuationScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 14/06/24.
//

import Foundation
import GameplayKit
import SpriteKit
class EvacuationScene: SKScene{
	private var evacuationLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    private let retryButton = RetryButton.newInstance()
    private let helicopterSprite = HelicopterSprite.newInstance()
    
	override func didMove(to view: SKView) {
		evacuationLabel.text = "You have been evacuated!"
		evacuationLabel.fontSize = 40
		evacuationLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
		addChild(evacuationLabel)
        
        helicopterSprite.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        addChild(helicopterSprite)
        
		retryButton.position = CGPoint(x: frame.maxX - 100, y: frame.minY / 2 + 50)
        addChild(retryButton)
	}
}
