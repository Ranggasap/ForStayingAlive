//
//  PlayerSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit

public class HeroSprite : SKSpriteNode {
	private let heroWalkingKey = "hero_walking"
	private let heroRunningKey = "hero_running"
	
	public static func newInstance() -> HeroSprite {
		let playerHero = HeroSprite(imageNamed: "player-test-normal")
		playerHero.size = CGSize(width: playerHero.size.width * 1.5, height: playerHero.size.height * 1.5)
		playerHero.zPosition = 1
		
		playerHero.physicsBody =  SKPhysicsBody(rectangleOf: CGSize(width: playerHero.size.width / 2, height: playerHero.size.height / 2))
		playerHero.physicsBody?.affectedByGravity = false
		playerHero.physicsBody?.allowsRotation = false
		
		playerHero.physicsBody?.categoryBitMask = HeroCategory
		playerHero.physicsBody?.contactTestBitMask = UndeadCategory
		
		return playerHero
	}
	
	// Frames for walking animation
	private let walkingFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-test-walk\(i)")
	}
	
	// Frames for running animation
	private let runningFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-test-run\(i)")
	}
	
	public func heroWalkingAnimation() {
		if action(forKey: heroWalkingKey) == nil {
			let walkingAnimation = SKAction.repeatForever(
				SKAction.animate(with: walkingFrames, timePerFrame: 0.1))
			run(walkingAnimation, withKey: heroWalkingKey)
		}
	}
	
	public func heroRunningAnimation() {
		if action(forKey: heroRunningKey) == nil {
			let runningAnimation = SKAction.repeatForever(
				SKAction.animate(with: runningFrames, timePerFrame: 0.1))
			run(runningAnimation, withKey: heroRunningKey)
		}
	}
	
	public func heroIsMoving(isRunning : Bool, joystickPosition : CGPoint) {
		// Calculate velocity based on the position of joystick's stick
		let velocity = CGVector(dx: joystickPosition.x, dy: joystickPosition.y)
		
		// Check if the velocity magnitude is greater than zero
		if hypot(velocity.dx, velocity.dy) > 0 {
			// Determine the direction of movement
			let isMovingLeft = velocity.dx < 0
			
			// Update hero's facing direction
			self.xScale = isMovingLeft ? -1 : 1
			
			if isRunning {
				// If the hero is moving and the running button is pressed, trigger the running animation
				self.removeAction(forKey: heroWalkingKey)
				self.heroRunningAnimation()
			} else {
				// If the hero is moving but the running button is not pressed, trigger the walking animation
				self.removeAction(forKey: heroRunningKey)
				self.heroWalkingAnimation()
			}
		} else {
			// If the hero is not moving, remove all animations
			self.removeAllActions()
		}
	}
}
