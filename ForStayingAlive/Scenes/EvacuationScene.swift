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
    
    private var retryButton = RetryButton.newInstance()
    
    private var helicopterSprite = HelicopterSprite.newInstance()
    
	override func didMove(to view: SKView) {
		evacuationLabel.text = "You have been evacuated!"
		evacuationLabel.fontSize = 40
		evacuationLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
		addChild(evacuationLabel)
        
        helicopterSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(helicopterSprite)
        
        retryButton.position = CGPoint(x: frame.width - 75, y: 50)
        addChild(retryButton)
	}
}
