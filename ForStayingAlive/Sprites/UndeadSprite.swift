//
//  UndeadSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 09/06/24.
//

import SpriteKit

public class UndeadSprite : SKSpriteNode {
	private let undeadSpeed : CGFloat = 115
	private let senseRadius : CGFloat = 165
	
	private let undeadIdleKey = "undead_idle"
	private let undeadWalkingKey = "undead_walking"
	private let undeadAttackingKey = "undead_attacking"
	
	private var undeadSpawnPosition: CGPoint!
		
	public static func newInstance() -> UndeadSprite {
		let undeadSprite = UndeadSprite(imageNamed: "undead-test-normal")
		undeadSprite.size = CGSize(width: undeadSprite.size.width * 2, height: undeadSprite.size.height * 2)
		undeadSprite.zPosition = 3
		
		undeadSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: undeadSprite.size.width / 2, height: undeadSprite.size.height))
		undeadSprite.physicsBody?.affectedByGravity = false
		undeadSprite.physicsBody?.allowsRotation = false
		undeadSprite.physicsBody?.pinned = false
		
		undeadSprite.physicsBody?.categoryBitMask = UndeadCategory
		undeadSprite.physicsBody?.contactTestBitMask = HeroCategory
		
		return undeadSprite
	}
	
	public func setUndeadSpawnPosition() {
		self.undeadSpawnPosition = self.position
	}
	
	private let idleFrames: [SKTexture] = (0...3).flatMap { i in
		Array(repeating: SKTexture(imageNamed: "undead-test-idle\(i)"), count: i == 0 ? 3 : 2)
	}
	
	private let walkingFrames: [SKTexture] = (0...5).map { i in
		SKTexture(imageNamed: "undead-test-walk\(i)")
	}
	
	private let attackingFrames: [SKTexture] = (0...5).map { i in
		SKTexture(imageNamed: "undead-test-attack\(i)")
	}
	
	public func undeadIdleAnimation() {
		removeAction(forKey: undeadWalkingKey)
		removeAction(forKey: undeadAttackingKey)
		if action(forKey: undeadIdleKey) == nil {
			let idleAnimation = SKAction.repeatForever(
				SKAction.animate(with: idleFrames, timePerFrame: 0.1))
			run(idleAnimation, withKey: undeadIdleKey)
		}
	}
	
	public func undeadWalkingAnimation() {
		removeAction(forKey: undeadIdleKey)
		removeAction(forKey: undeadAttackingKey)
		if action(forKey: undeadWalkingKey) == nil {
			let walkingAnimation = SKAction.repeatForever(
				SKAction.animate(with: walkingFrames, timePerFrame: 0.1))
			run(walkingAnimation, withKey: undeadWalkingKey)
		}
	}
	
	public func undeadAttackingAnimation() {
		removeAction(forKey: undeadIdleKey)
		removeAction(forKey: undeadWalkingKey)
		if action(forKey: undeadAttackingKey) == nil {
			let attackingAnimation = SKAction.repeatForever(
				SKAction.animate(with: attackingFrames, timePerFrame: 0.1))
			run(attackingAnimation, withKey: undeadAttackingKey)
		}
	}
		
	public func undeadIsAttacking(deltaTime: TimeInterval, hero: SKSpriteNode) {
		let distanceToHero = hypot(hero.position.x - self.position.x, hero.position.y - self.position.y)
		
		if distanceToHero <= senseRadius {
			if self.physicsBody?.pinned == false {
				let angle = atan2(hero.position.y - self.position.y, hero.position.x - self.position.x)
				let moveSpeed = undeadSpeed * CGFloat(deltaTime)
				let moveX = cos(angle) * moveSpeed
				let moveY = sin(angle) * moveSpeed
				
				position = CGPoint(
					x: position.x + moveX,
					y: position.y + moveY
				)
				
				let isMovingLeft = moveX < 0
				self.xScale = isMovingLeft ? -1 : 1
			}
			self.undeadAttackingAnimation()
		} else {
			undeadIsReturning()
		}
	}
	
	private func undeadIsReturning() {
		let distanceToSpawn = hypot(self.undeadSpawnPosition.x - self.position.x, self.undeadSpawnPosition.y - self.position.y)
		if distanceToSpawn > 1 {
			let undeadReturning = SKAction.move(to: undeadSpawnPosition, duration: TimeInterval(distanceToSpawn / undeadSpeed))
			let undeadWalking = SKAction.run { [weak self] in
				self?.undeadWalkingAnimation()
				if let self = self {
					let isMovingLeft = self.undeadSpawnPosition.x < self.position.x
					self.xScale = isMovingLeft ? -1 : 1
				}
			}
			let undeadMovingToSpawnPosition = SKAction.group([undeadReturning, undeadWalking])
			run(undeadMovingToSpawnPosition)
		} else {
			self.undeadIdleAnimation()
		}
	}
}
