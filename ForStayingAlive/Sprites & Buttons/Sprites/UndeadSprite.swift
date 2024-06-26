//
//  UndeadSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 09/06/24.
//

import SpriteKit

public class UndeadSprite : SKSpriteNode {
	private let undeadSpeed : CGFloat = 115
	private let undeadSenseRadius : CGFloat = 165
	private let undeadAttackRange : CGFloat = 60
	private let undeadSpawnPositionToleranceArea : CGFloat = 5
	
	private let undeadIdleKey = "undead_idle"
	private let undeadWalkingKey = "undead_walking"
	private let undeadAttackingKey = "undead_attacking"
	
	private var undeadSpawnPosition: CGPoint!
	
	var onHeroEnterAttackRange: (() -> Void)?
	var onHeroExitAttackRange: (() -> Void)?
	
	public static func newInstance() -> UndeadSprite {
		let undeadSprite = UndeadSprite(imageNamed: "undead-normal")
		undeadSprite.size = CGSize(width: undeadSprite.size.width / 1.5, height: undeadSprite.size.height / 1.5)
		undeadSprite.zPosition = 2
		
		undeadSprite.physicsBody = SKPhysicsBody(circleOfRadius: undeadSprite.size.width / 3)
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
	
	public func getUndeadAttackRange() -> CGFloat {
		return undeadAttackRange
	}
	
	private let idleFrames: [SKTexture] = (0...3).flatMap { i in
		Array(repeating: SKTexture(imageNamed: "undead-idle\(i)"), count: 2)
	}
	
	private let walkingFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "undead-walk\(i)")
	}
	
	private let attackingFrames: [SKTexture] = (0...5).map { i in
		SKTexture(imageNamed: "undead-run\(i)")
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
				SKAction.animate(with: walkingFrames, timePerFrame: 0.15))
			run(walkingAnimation, withKey: undeadWalkingKey)
		}
	}
	
	public func undeadAttackingAnimation() {
		removeAction(forKey: undeadIdleKey)
		removeAction(forKey: undeadWalkingKey)
		if action(forKey: undeadAttackingKey) == nil {
			let attackingSound = SKAction.playSoundFileNamed("undead-attack", waitForCompletion: false)
			let attackingAnimation = SKAction.repeatForever(
				SKAction.animate(with: attackingFrames, timePerFrame: 0.1))
			let attackingGroup = SKAction.group([attackingSound, attackingAnimation])
			run(attackingGroup, withKey: undeadAttackingKey)
		}
	}
	
	public func undeadIsAttacking(deltaTime: TimeInterval, hero: SKSpriteNode, heroIsHidden: Bool) {
		let distanceToHero = hypot(hero.position.x - self.position.x, hero.position.y - self.position.y)
		
		if heroIsHidden {
			self.physicsBody?.pinned = false
		}
		
		if !heroIsHidden && distanceToHero <= undeadSenseRadius {
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
            self.physicsBody?.collisionBitMask = WallCategory | ChestCategory | LockerCategory
			
			if distanceToHero <= undeadAttackRange {
				onHeroEnterAttackRange?()
			} else {
				onHeroExitAttackRange?()
			}
		} else {
			undeadIsReturning(deltaTime: deltaTime)
			onHeroExitAttackRange?()
		}
	}
	
	private func undeadIsReturning(deltaTime: TimeInterval) {
		let distanceToSpawnPosition = hypot(self.undeadSpawnPosition.x - self.position.x, self.undeadSpawnPosition.y - self.position.y)
		if distanceToSpawnPosition > undeadSpawnPositionToleranceArea {
			let angle = atan2(undeadSpawnPosition.y - self.position.y, undeadSpawnPosition.x - self.position.x)
			let moveSpeed = undeadSpeed * CGFloat(deltaTime)
			let moveX = cos(angle) * moveSpeed
			let moveY = sin(angle) * moveSpeed
			
			position = CGPoint(
				x: position.x + moveX,
				y: position.y + moveY
			)
			
			let isMovingLeft = moveX < 0
			self.xScale = isMovingLeft ? -1 : 1
			
			self.undeadWalkingAnimation()
            self.physicsBody?.collisionBitMask = 0
		} else {
			self.position = undeadSpawnPosition
			self.undeadIdleAnimation()
		}
	}
}
