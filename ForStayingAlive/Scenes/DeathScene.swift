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
	private let undeadOne = UndeadSprite.newInstance()
	private let undeadTwo = UndeadSprite.newInstance()
	
	override func didMove(to view: SKView) {
		deathLabel.text = "Your life has ended..."
		deathLabel.fontSize = 40
		deathLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
		addChild(deathLabel)
		
		hero.position = CGPoint(x: frame.midX, y: frame.midY - 50)
		hero.size = CGSize(width: hero.size.width * 2, height: hero.size.height * 2)
		addChild(hero)
		hero.heroDyingAnimation()
		
		undeadOne.position = CGPoint(x: frame.midX - 90, y: frame.midY - 50)
		undeadOne.size = CGSize(width: undeadOne.size.width * 2, height: undeadOne.size.height * 2)
		addChild(undeadOne)
		undeadOne.undeadIdleAnimation()
		
		undeadTwo.position = CGPoint(x: frame.midX + 90, y: frame.midY - 50)
		undeadTwo.size = CGSize(width: undeadTwo.size.width * 2, height: undeadTwo.size.height * 2)
		undeadTwo.xScale = -1
		addChild(undeadTwo)
		undeadTwo.undeadIdleAnimation()
		
		retryButton.position = CGPoint(x: frame.maxX - 100, y: frame.minY / 2 + 50)
		addChild(retryButton)
	}
}
