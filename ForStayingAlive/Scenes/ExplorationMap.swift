//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap: SKScene, SKPhysicsContactDelegate {
	private let hero = HeroSprite.newInstance()
	private let undead = UndeadSprite.newInstance()
	private let chest = ChestSprite.newInstance()
	private let locker = LockerSprite.newInstance()
	
	private let runningButton = RunningButton.newInstance()
	private let interactButton = InteractButton.newInstance()
	private let hidingButton = HidingButton.newInstance()
	
	private let heroCamera = SKCameraNode()
	
	private var joystick: AnalogJoystick!
	
	private var backgroundOne: SKSpriteNode!
	private var backgroundTwo: SKSpriteNode!
	
	private var lastUpdateTime: TimeInterval = 0
	
	private var minX: CGFloat = 0
	private var maxX: CGFloat = 0
	private var minY: CGFloat = 0
	private var maxY: CGFloat = 0
	
	override func didMove(to view: SKView) {
		physicsWorld.contactDelegate = self
		
		setupHeroCamera()
		addBackground()
		addJoystick()
		addRunningButton()
		addInteractButton()
		addHidingButton()
		spawnHero()
		spawnUndead()
		spawnChest()
		spawnLocker()
		
//		minX = frame.minX + 70
//		maxX = backgroundOne.position.x + backgroundTwo.position.x - 70
//		minY = frame.minY + 50
//		maxY = frame.midY + 70
	}
	
	func addBackground() {
		backgroundOne = SKSpriteNode(imageNamed: "background")
		backgroundOne.size = self.size
		backgroundOne.position = CGPoint(x: frame.midX, y: frame.midY)
		backgroundOne.zPosition = -1
		addChild(backgroundOne)
		
		backgroundTwo = SKSpriteNode(imageNamed: "background")
		backgroundTwo.size = self.size
		backgroundTwo.position = CGPoint(x: backgroundOne.position.x + backgroundTwo.frame.width / 2, y: frame.midY)
		backgroundTwo.zPosition = -1
		addChild(backgroundTwo)
	}
	
	func addJoystick() {
		let joystickDiameter: CGFloat = min(size.width, size.height) * 0.2
		
		let substrate = AnalogJoystickSubstrate(diameter: joystickDiameter, borderColor: .gray, fillColor: .white)
		substrate.borderWidth = 10.0
		
		let stick = AnalogJoystickStick(diameter: joystickDiameter * 0.6, borderColor: .gray, fillColor: .gray)
		
		joystick = AnalogJoystick(substrate: substrate, stick: stick)
		joystick.position = CGPoint(x: -size.width / 2 + 150, y: -size.height / 2 + 100)
		joystick.zPosition = 10
		
		heroCamera.addChild(joystick)
		
		joystick.trackingHandler = { [unowned self] data in
			let velocity = data.velocity
			let moveSpeed: CGFloat = self.runningButton.isPressed ? 0.35 : 0.2
			self.hero.position = CGPoint(x: self.hero.position.x + velocity.x * moveSpeed, y: self.hero.position.y + velocity.y * moveSpeed)
		}
	}
	
	func addRunningButton() {
		runningButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 100)
		runningButton.zPosition = 10
		heroCamera.addChild(runningButton)
	}
	
	func addInteractButton() {
		interactButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 170)
		interactButton.zPosition = 10
		heroCamera.addChild(interactButton)
	}
	
	func addHidingButton() {
		hidingButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 170)
		hidingButton.zPosition = 10
		heroCamera.addChild(hidingButton)
	}
	
	func setupHeroCamera() {
		camera = heroCamera
		heroCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
		addChild(heroCamera)
	}
	
	func spawnHero() {
		hero.position = CGPoint(x: frame.midX - 100, y: frame.midY)
		addChild(hero)
	}
	
	func spawnUndead() {
		undead.position = CGPoint(x: frame.midX + 200, y: frame.midY)
		undead.setUndeadSpawnPosition()
		addChild(undead)
	}
	
	func spawnChest() {
		chest.position = CGPoint(x: frame.midX, y: frame.midY - 100)
		addChild(chest)
	}
	
	func spawnLocker() {
		locker.position = CGPoint(x: frame.minX + 100, y: frame.midY + 50)
		addChild(locker)
	}
	
	func clampPosition(of node: SKNode) {
		node.position.x = min(maxX, max(minX, node.position.x))
		node.position.y = min(maxY, max(minY, node.position.y))
	}
	
	func handleChestCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == ChestCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case HeroCategory:
				interactButton.isHidden = false
			default:
				break
		}
	}
	
	func handleLockerCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == LockerCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case HeroCategory:
				hidingButton.isHidden = false
			default:
				break
		}
	}
	
	func handleHeroCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == HeroCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case UndeadCategory:
				undead.physicsBody?.pinned = true
			default:
				break
		}
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.categoryBitMask == ChestCategory || contact.bodyB.categoryBitMask == ChestCategory {
			handleChestCollision(contact: contact)
			
			return
		}
		
		if contact.bodyA.categoryBitMask == LockerCategory || contact.bodyB.categoryBitMask == LockerCategory {
			handleLockerCollision(contact: contact)
			
			return
		}
		
		if contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory {
			handleHeroCollision(contact: contact)
			
			return
		}
	}
	
	func didEnd(_ contact: SKPhysicsContact) {
		if contact.bodyA.categoryBitMask == ChestCategory || contact.bodyB.categoryBitMask == ChestCategory {
			if (contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory) {
				interactButton.isHidden = true
			}
		}
		
		if contact.bodyA.categoryBitMask == LockerCategory || contact.bodyB.categoryBitMask == LockerCategory {
			if (contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory) {
				hidingButton.isHidden = true
			}
		}
		
		if contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory {
			if (contact.bodyA.categoryBitMask == UndeadCategory || contact.bodyB.categoryBitMask == UndeadCategory) {
				undead.physicsBody?.pinned = false
			}
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
//		clampPosition(of: hero)
//		clampPosition(of: undead)
		
//		let cameraX = max(hero.position.x, size.width / 2)
//		let maxCameraX = backgroundOne.position.x + backgroundTwo.frame.width / 2
//		heroCamera.position.x = min(maxCameraX, cameraX)
		
		heroCamera.position = hero.position
		
		let isRunning = runningButton.isPressed
		let joystickPosition = joystick.stick.position
		
		hero.heroIsMoving(isRunning: isRunning, joystickPosition: joystickPosition)
		undead.undeadIsAttacking(deltaTime: dt, hero: hero)
	}
}
