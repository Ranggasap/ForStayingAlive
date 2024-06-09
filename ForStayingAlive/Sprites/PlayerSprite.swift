//
//  PlayerSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit

public class PlayerSprite : SKSpriteNode {
	let heroWalkingKey = "hero_walking"
	let heroRunningKey = "hero_running"
	
	public static func newInstance() -> PlayerSprite {
		let playerHero = PlayerSprite(imageNamed: "player-test-normal")
		playerHero.size = CGSize(width: playerHero.size.width * 1.5, height: playerHero.size.height * 1.5)
		playerHero.zPosition = 1
		
		playerHero.physicsBody =  SKPhysicsBody(rectangleOf: CGSize(width: playerHero.size.width / 2, height: playerHero.size.height / 2))
		playerHero.physicsBody?.affectedByGravity = false
		playerHero.physicsBody?.allowsRotation = false
		playerHero.physicsBody?.friction = 0
		playerHero.physicsBody?.restitution = 0
		
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
}
