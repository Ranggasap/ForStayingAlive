//
//  UndeadSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 09/06/24.
//

import SpriteKit

public class UndeadSprite : SKSpriteNode {
	private let undeadSpeed : CGFloat = 120
	private let senseRadius : CGFloat = 170
	
	private let undeadWalkingKey = "undead_walking"
	
	public static func newInstance() -> UndeadSprite {
		let undeadSprite = UndeadSprite(imageNamed: "undead-test-normal")
		undeadSprite.size = CGSize(width: undeadSprite.size.width * 2.5, height: undeadSprite.size.height * 2.5)
		undeadSprite.zPosition = 1
		
		undeadSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: undeadSprite.size.width / 2, height: undeadSprite.size.height / 2))
		undeadSprite.physicsBody?.affectedByGravity = false
		undeadSprite.physicsBody?.allowsRotation = false
		
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
	
	public func chasePlayer(deltaTime : TimeInterval, hero : SKSpriteNode) {
		// Handle undead following hero
		let undeadToHeroDistance = hypot(hero.position.x - position.x, hero.position.y - position.y)
		
		if undeadToHeroDistance <= senseRadius {
			let angle = atan2(hero.position.y - position.y, hero.position.x - position.x)
			let moveSpeed = undeadSpeed * CGFloat(deltaTime)
			let moveX = cos(angle) * moveSpeed
			let moveY = sin(angle) * moveSpeed
			
			// Update undead position
			position = CGPoint(
				x: position.x + moveX,
				y: position.y + moveY
			)
			
			// Determine the direction of movement
			let isMovingLeft = moveX < 0
			
			// Update undead's facing direction
			xScale = isMovingLeft ? -1 : 1
			
			undeadWalkingAnimation()
		} else {
			// If the undead is not within sense radius, stop the animation
			removeAllActions()
		}
	}
}
