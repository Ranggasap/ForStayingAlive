//
//  UndeadSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 09/06/24.
//

import SpriteKit

public class UndeadSprite : SKSpriteNode {
	let undeadSpeed : CGFloat = 80
	let senseRadius : CGFloat = 160
	
	let undeadWalkingKey = "undead_walking"
	
	public static func newInstance() -> UndeadSprite {
		let undeadSprite = UndeadSprite(imageNamed: "undead-test-normal")
		undeadSprite.size = CGSize(width: undeadSprite.size.width * 2.5, height: undeadSprite.size.height * 2.5)
		undeadSprite.zPosition = 1
		
		undeadSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: undeadSprite.size.width / 2, height: undeadSprite.size.height / 2))
		undeadSprite.physicsBody?.affectedByGravity = false
		undeadSprite.physicsBody?.allowsRotation = false
		undeadSprite.physicsBody?.friction = 0
		undeadSprite.physicsBody?.restitution = 0
		
		undeadSprite.physicsBody?.categoryBitMask = UndeadCategory
		undeadSprite.physicsBody?.contactTestBitMask = HeroCategory
		
		return undeadSprite
	}
	
	// Frames for walking animation
	private let walkingFrames: [SKTexture] = (0...5).map { i in
		SKTexture(imageNamed: "undead-test-walk\(i)")
	}
	
	public func undeadWalkingAnimation() {
		if action(forKey: undeadWalkingKey) == nil {
			let walkingAnimation = SKAction.repeatForever(
				SKAction.animate(with: walkingFrames, timePerFrame: 0.1))
			run(walkingAnimation, withKey: undeadWalkingKey)
		}
	}
}
