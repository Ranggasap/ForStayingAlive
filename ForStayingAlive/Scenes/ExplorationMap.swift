//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap : SKScene {
	
	private let hero = PlayerSprite.newInstance()
	
	override func didMove(to view: SKView) {
		
		createBackground()
		spawnPlayerHero()
	}
	
	func spawnPlayerHero() {
		hero.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(hero)
	}
	
	func createBackground() {
		let screenSize = self.size
		let backgroundImage = SKSpriteNode(imageNamed: "sky")
		
		backgroundImage.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
		backgroundImage.position = CGPoint(x: screenSize.width / 2, y: screenSize.height - backgroundImage.size.height / 2)
		
		let colorNode = SKSpriteNode(color: UIColor(named: "terrain-color") ?? .white, size: CGSize(width: screenSize.width, height: screenSize.height / 2))
		colorNode.position = CGPoint(x: screenSize.width / 2, y: colorNode.size.height / 2)
		
		addChild(backgroundImage)
		addChild(colorNode)
	}
}
