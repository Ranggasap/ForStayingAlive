//
//  PlayerSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit

public class HeroSprite : SKSpriteNode {
	private let heroIdleKey = "hero_idle"
	private let heroWalkingKey = "hero_walking"
	private let heroRunningKey = "hero_running"
	
	private var heroHealth : CGFloat = 100
	private var heroStamina : CGFloat = 100
	
	public static func newInstance() -> HeroSprite {
		let playerHero = HeroSprite(imageNamed: "player-hero-normal")
		playerHero.size = CGSize(width: playerHero.size.width / 1.5, height: playerHero.size.height / 1.5)
		playerHero.zPosition = 2
		playerHero.isHidden = false
		
		playerHero.physicsBody =  SKPhysicsBody(rectangleOf: CGSize(width: playerHero.size.width / 2, height: playerHero.size.height / 2))
		playerHero.physicsBody?.affectedByGravity = false
		playerHero.physicsBody?.allowsRotation = false
		
		playerHero.physicsBody?.categoryBitMask = HeroCategory
		playerHero.physicsBody?.contactTestBitMask = UndeadCategory | ChestCategory | LockerCategory
		
		return playerHero
	}
	
	public func isHeroIdle() -> Bool {
		return action(forKey: heroIdleKey) != nil
	}
	
	override public var isHidden: Bool {
		didSet {
			if isHidden {
				self.removePhysicsBody()
			} else {
				self.addPhysicsBody()
			}
		}
	}
	
	private func removePhysicsBody() {
		self.physicsBody = nil
	}
	
	private func addPhysicsBody() {
		let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width / 2, height: self.size.height / 2))
		physicsBody.affectedByGravity = false
		physicsBody.allowsRotation = false
		physicsBody.categoryBitMask = HeroCategory
		physicsBody.contactTestBitMask = UndeadCategory | ChestCategory | LockerCategory
		self.physicsBody = physicsBody
	}
	
	private let idleFrames: [SKTexture] = (0...3).flatMap { i in
		Array(repeating: SKTexture(imageNamed: "player-hero-idle\(i)"), count: 2)
	}
	
	private let walkingFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-hero-walk\(i)")
	}
	
	private let runningFrames: [SKTexture] = (0...5).map { i in
		SKTexture(imageNamed: "player-hero-run\(i)")
	}
	
	public func heroIdleAnimation() {
		removeAction(forKey: heroRunningKey)
		removeAction(forKey: heroWalkingKey)
		if action(forKey: heroIdleKey) == nil {
			let idleAnimation = SKAction.repeatForever(
				SKAction.animate(with: idleFrames, timePerFrame: 0.1))
			run(idleAnimation, withKey: heroIdleKey)
		}
	}
	
	public func heroWalkingAnimation() {
		removeAction(forKey: heroIdleKey)
		removeAction(forKey: heroRunningKey)
		if action(forKey: heroWalkingKey) == nil {
			let walkingAnimation = SKAction.repeatForever(
				SKAction.animate(with: walkingFrames, timePerFrame: 0.15))
			run(walkingAnimation, withKey: heroWalkingKey)
		}
	}
	
	public func heroRunningAnimation() {
		removeAction(forKey: heroIdleKey)
		removeAction(forKey: heroWalkingKey)
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
				self.heroRunningAnimation()
			} else {
				self.heroWalkingAnimation()
			}
		} else {
			self.heroIdleAnimation()
		}
	}
	
	public func getHeroHealth() -> (CGFloat) {
		return(heroHealth)
	}
	
	public func getHeroStamina() -> (CGFloat) {
		return(heroStamina)
	}
	
	public func heroHealthReduced(health: CGFloat) {
		self.heroHealth -= health
		
		if self.heroHealth == 0 {
			if let scene = self.scene{
				let deathScene = DeathScene(size: scene.size)
				deathScene.scaleMode = .aspectFit
				let transition = SKTransition.fade(withDuration: 1.0)
				scene.view?.presentScene(deathScene, transition: transition)
			}
		}
	}
	
	public func heroHealthIncreased(health: CGFloat) {
		self.heroHealth += health
		
		if self.heroHealth > 100 {
			self.heroHealth = 100
		}
	}
	
	public func heroStaminaReduced(stamina: CGFloat) {
		self.heroStamina -= stamina
		
		if self.heroStamina < 0 {
			self.heroStamina = 0
		}
	}
	
	public func heroStaminaIncreased(stamina: CGFloat) {
		self.heroStamina += stamina
		
		if self.heroStamina > 100 {
			self.heroStamina = 100
		}
	}
}
