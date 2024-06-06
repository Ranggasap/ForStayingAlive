//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap: SKScene, SKPhysicsContactDelegate {
	
	private let undead = UndeadSprite.newInstance()
	
	override func didMove(to view: SKView) {
		self.physicsWorld.contactDelegate = self
		
		createBackground()
		createPlayBoundary()
		spawnUndead()
	}
	
	func spawnUndead() {
		undead.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2 - 50)
		
		addChild(undead)
	}
	
	func createBackground() {
		// Get the screen size
		let screenSize = self.size
		
		// Calculate the height for the bottom half
		let halfHeight = screenSize.height / 2
		
		// Create a sprite node with the custom color
		let terrainNode = SKSpriteNode(color: UIColor(named: "terrain-color") ?? .black, size: CGSize(width: screenSize.width, height: halfHeight))
		
		// Position the node at the bottom half of the screen
		terrainNode.position = CGPoint(x: screenSize.width / 2, y: halfHeight / 2)
		terrainNode.zPosition = 0
		
		// Add the node to the scene
		addChild(terrainNode)
		
		// Set the background color of the remaining part (optional)
		self.backgroundColor = .white  // Set this to the desired color for the top half
	}
	
	func createPlayBoundary() {
		let horizonLine = SKNode()
		horizonLine.position = CGPoint(x: size.width / 2, y: size.height / 2)
		
		// Create a physics body for horizon
		let horizonPhysicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width / 2, y: 0))
		horizonPhysicsBody.isDynamic = false
		horizonLine.physicsBody = horizonPhysicsBody
		
		addChild(horizonLine)
		
		// Create a physics body for floor
		let floorNode = SKNode()
		floorNode.position = CGPoint(x: size.width / 2, y: 20)
		
		floorNode.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: -size.width / 2, y: 0), to: CGPoint(x: size.width, y: 0))
		
		addChild(floorNode)
	}
}
