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
	private let runningButton = RunningButton.newInstance()
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
		setupHeroCamera()
		addBackground()
		addJoystick()
		addRunningButton()
		spawnHero()
		spawnUndead()
		
		minX = frame.minX + 70
		maxX = backgroundOne.position.x + backgroundTwo.position.x - 70
		minY = frame.minY + 50
		maxY = frame.midY + 70
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
		addChild(undead)
	}
	
	func clampPosition(of node: SKNode) {
		node.position.x = min(maxX, max(minX, node.position.x))
		node.position.y = min(maxY, max(minY, node.position.y))
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		clampPosition(of: hero)
		clampPosition(of: undead)
		
		let cameraX = max(hero.position.x, size.width / 2)
		let maxCameraX = backgroundOne.position.x + backgroundTwo.frame.width / 2
		heroCamera.position.x = min(maxCameraX, cameraX)
		
		let isRunning = runningButton.isPressed
		let joystickPosition = joystick.stick.position
		
		hero.heroIsMoving(isRunning: isRunning, joystickPosition: joystickPosition)
		undead.undeadIsAttacking(deltaTime: dt, hero: hero)
	}
}
