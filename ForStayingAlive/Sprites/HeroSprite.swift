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
    
    private var health: CGFloat = 100
    private var stamina: CGFloat = 100
    
    private var hungerTime: TimeInterval = 0
	
	public static func newInstance() -> HeroSprite {
		let playerHero = HeroSprite(imageNamed: "player-test-normal")
		playerHero.size = CGSize(width: playerHero.size.width, height: playerHero.size.height)
		playerHero.zPosition = 2
		playerHero.isHidden = false
		
		playerHero.physicsBody =  SKPhysicsBody(rectangleOf: CGSize(width: playerHero.size.width / 2, height: playerHero.size.height / 2))
		playerHero.physicsBody?.affectedByGravity = false
		playerHero.physicsBody?.allowsRotation = false
		
		playerHero.physicsBody?.categoryBitMask = HeroCategory
		playerHero.physicsBody?.contactTestBitMask = UndeadCategory | ChestCategory | NextSceneCategory
		
		return playerHero
	}
    
    public func update(deltaTime: TimeInterval){
        hungerTime += deltaTime
        
        if hungerTime > 3{
            hungerTime = 0
            health -= 10
            stamina -= 10
        }
    }
    
    public func getStatus()->(CGFloat, CGFloat){
        return (health, stamina)
    }
    
    public func healthReduce(health: CGFloat){
        self.health = self.health - health
        if self.health <= 0 {
            if let scene = self.scene{
                let gameOverScene = GameOverScene(size: scene.size)
                gameOverScene.scaleMode = .aspectFit
                let transition = SKTransition.fade(withDuration: 1.0)
                scene.view?.presentScene(gameOverScene, transition: transition)
            }
        }
        
    }
	
	private let idleFrames: [SKTexture] = (0...1).flatMap { i in
		Array(repeating: SKTexture(imageNamed: "player-test-idle\(i)"), count: 3)
	}
	
	private let walkingFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-test-walk\(i)")
	}
	
	private let runningFrames: [SKTexture] = (0...3).map { i in
		SKTexture(imageNamed: "player-test-run\(i)")
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
				SKAction.animate(with: walkingFrames, timePerFrame: 0.1))
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
}
