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
		playerHero.size = CGSize(width: playerHero.size.width, height: playerHero.size.height)
		playerHero.zPosition = 2
		
		playerHero.physicsBody =  SKPhysicsBody(rectangleOf: CGSize(width: playerHero.size.width / 2, height: playerHero.size.height / 2))
		playerHero.physicsBody?.affectedByGravity = false
		playerHero.physicsBody?.allowsRotation = false
		
		playerHero.physicsBody?.categoryBitMask = HeroCategory
		playerHero.physicsBody?.contactTestBitMask = UndeadCategory | ChestCategory
		
		return playerHero
	}
	
	private let walkingFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-test-walk\(i)")
	}
	
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
		let velocity = CGVector(dx: joystickPosition.x, dy: joystickPosition.y)
		
		if hypot(velocity.dx, velocity.dy) > 0 {
			let isMovingLeft = velocity.dx < 0
			
			self.xScale = isMovingLeft ? -1 : 1
			
			if isRunning {
				self.removeAction(forKey: heroWalkingKey)
				self.heroRunningAnimation()
			} else {
				self.removeAction(forKey: heroRunningKey)
				self.heroWalkingAnimation()
			}
		} else {
			self.removeAllActions()
		}
	}
}
