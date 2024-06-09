//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap: SKScene, SKPhysicsContactDelegate {
	private let hero = PlayerSprite.newInstance()
	private let undead = UndeadSprite.newInstance()
	private let runningButton = RunningButton.newInstance()
	private let heroCamera = SKCameraNode()
	
	private var joystick: AnalogJoystick!
	private var joystickOverlay = SKNode()
	
	private var backgroundImageOne: SKSpriteNode!
	private var backgroundImageTwo: SKSpriteNode!
	
	private var lastUpdateTime : TimeInterval = 0
	
	var minX: CGFloat = 0
	var maxX: CGFloat = 0
	var minY: CGFloat = 0
	var maxY: CGFloat = 0
	
	override func didMove(to view: SKView) {
		createBackground()
		addPlayerHero()
		addUndead()
		setupCamera()
		
		// Set the boundary
		minX = frame.minX + 50
		maxX = backgroundImageTwo.position.x - 50
		minY = frame.minY + 50
		maxY = frame.midY + 70
	}
	
	func addPlayerHero() {
		hero.position = CGPoint(
			x: frame.midX - 100,
			y: frame.midY
		)
		addChild(hero)
	}
	
	func addUndead() {
		undead.position = CGPoint(
			x: frame.midX + 200,
			y: frame.midY
		)
		addChild(undead)
	}

	func addJoystick() {
		let joystickDiameter: CGFloat = min(size.width, size.height) * 0.2
		
		let substrate = AnalogJoystickSubstrate(
			diameter: joystickDiameter,
			borderColor: .gray, fillColor: .white
		)
		substrate.borderWidth = 10.0
		
		let stick = AnalogJoystickStick(
			diameter: joystickDiameter * 0.6,
			borderColor: .gray, fillColor: .gray
		)
		
		joystick = AnalogJoystick(substrate: substrate, stick: stick)
		joystick.position = CGPoint(x: 0, y: 0)
		joystick.zPosition = 10
		
		joystickOverlay.addChild(joystick)
		
		joystick.trackingHandler = { [unowned self] data in
			let velocity = data.velocity
			let moveSpeed: CGFloat = self.runningButton.isPressed ? 0.4 : 0.2
			self.hero.position = CGPoint(
				x: self.hero.position.x + velocity.x * moveSpeed,
				y: self.hero.position.y + velocity.y * moveSpeed
			)
		}
		
		heroCamera.addChild(joystickOverlay)
	}
	
	func addRunningButton() {
		runningButton.position = CGPoint(
			x: size.width / 2 - runningButton.size.width / 2 - 70,
			y: -size.height / 2 + runningButton.size.height / 2 + 70
		)
		runningButton.zPosition = 10
		heroCamera.addChild(runningButton)
	}
	
	func setupCamera() {
		camera = heroCamera
		heroCamera.position = CGPoint(
			x: hero.position.x,
			y: size.height / 2
		)
		addChild(heroCamera)
		addJoystick()
		addRunningButton()
	}
	
	func createBackground() {
		let screenSize = self.size
		
		// Create the first background image
		backgroundImageOne = SKSpriteNode(imageNamed: "background")
		backgroundImageOne.size = screenSize
		backgroundImageOne.position = CGPoint(
			x: screenSize.width / 2,
			y: screenSize.height / 2
		)
		backgroundImageOne.zPosition = -1
		addChild(backgroundImageOne)
		
		// Create the second background image
		backgroundImageTwo = SKSpriteNode(imageNamed: "background")
		backgroundImageTwo.size = backgroundImageOne.size
		
		// Position the second background image right after the first one
		let backgroundImageTwoX = backgroundImageOne.position.x + backgroundImageOne.size.width
		let backgroundImageTwoY = screenSize.height / 2
		backgroundImageTwo.position = CGPoint(
			x: backgroundImageTwoX,
			y: backgroundImageTwoY
		)
		backgroundImageTwo.zPosition = 0
		addChild(backgroundImageTwo)
	}
	
	// Clamp hero and undead to boundary
	func clampPosition(of node: SKNode) {
		node.position.x = min(maxX, max(minX, node.position.x))
		node.position.y = min(maxY, max(minY, node.position.y))
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Initialize _lastUpdateTime if it has not already been
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		// Calculate time since last update
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		// Clamp position within the bounds
		clampPosition(of: hero)
		clampPosition(of: undead)
		
		// Update the camera position to follow the hero horizontally within bounds
		let cameraX = max(hero.position.x, size.width / 2)
		let maxCameraX = backgroundImageTwo.position.x - size.width / 2
		heroCamera.position.x = min(maxCameraX, cameraX)
		
		// Keep the joystick fixed relative to the camera
		let joystickPosX = -size.width / 2 + joystick.frame.width / 2 + 150
		let joystickPosY = -size.height / 2 + joystick.frame.height / 2 + 100
		joystick.position = CGPoint(x: joystickPosX, y: joystickPosY)
			
		// Check if the running button is pressed
		let isRunning = runningButton.isPressed
		
		// Get the position of the joystick's stick
		let joystickPosition = joystick.stick.position
		
		// Hande hero behavior to move
		hero.heroMoving(isRunning: isRunning, joystickPosition: joystickPosition)
		
		// Handle undead behavior to chase hero
		undead.chasePlayer(deltaTime: dt, hero: hero)
	}
}
