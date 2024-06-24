//
//  DeathScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 15/06/24.
//

import SpriteKit

class DeathScene: SKScene{
	private var deathLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
	private let retryButton = RetryButton.newInstance()
	private let hero = HeroSprite.newInstance()
	
	override func didMove(to view: SKView) {
		deathLabel.text = "Your life has ended..."
		deathLabel.fontSize = 40
		deathLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
		addChild(deathLabel)
		
		hero.position = CGPoint(x: frame.midX, y: frame.midY - 50)
		hero.size = CGSize(width: hero.size.width * 1.5, height: hero.size.height * 1.5)
		addChild(hero)
		hero.heroDyingAnimation()
		
		retryButton.position = CGPoint(x: frame.maxX - 100, y: frame.minY / 2 + 50)
		addChild(retryButton)
	}
}
