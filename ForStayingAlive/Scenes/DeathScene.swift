//
//  DeathScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 15/06/24.
//

import SpriteKit

class DeathScene: SKScene{
	private var deathLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	override func didMove(to view: SKView) {
		deathLabel.text = "You are dead!"
		deathLabel.fontSize = 40
		deathLabel.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(deathLabel)
	}
}
