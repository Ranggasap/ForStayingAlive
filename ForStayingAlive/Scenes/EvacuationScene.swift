//
//  EvacuationScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 14/06/24.
//

import SpriteKit

class EvacuationScene: SKScene{
	private var evacuationLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    
	override func didMove(to view: SKView) {
		evacuationLabel.text = "You have been evacuated!"
		evacuationLabel.fontSize = 40
		evacuationLabel.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(evacuationLabel)
	}
}
