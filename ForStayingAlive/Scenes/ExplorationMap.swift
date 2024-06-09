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
	
	override func didMove(to view: SKView) {
		createBackground()
		createBoundary()
		addPlayerHero()
		addUndead()
		setupCamera()
		addJoystick()
		addRunningButton()
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
	}
	
	func createBackground() {
		let screenSize = self.size
		
		// Create the first background image
		backgroundImageOne = SKSpriteNode(imageNamed: "background")
		backgroundImageOne.size = CGSize(
			width: screenSize.width,
			height: screenSize.height)
		backgroundImageOne.position = CGPoint(
			x: screenSize.width / 2,
			y: screenSize.height / 2
		)
		backgroundImageOne.zPosition = 0
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



	func createBoundary() {
		let screenSize = self.size
		
		// Horizon Boundary
		let horizonStartPoint = CGPoint(
			x: -screenSize.width,
			y: frame.midY + 100)
		let horizonEndPoint = CGPoint(
			x: backgroundImageTwo.position.x + screenSize.width,
			y: frame.midY + 100
		)
		let horizonBoundaryBody = SKPhysicsBody(edgeFrom: horizonStartPoint, to: horizonEndPoint)
		let horizonBoundary = SKNode()
		horizonBoundary.physicsBody = horizonBoundaryBody
		addChild(horizonBoundary)
		
		// Ground Boundary
		let groundStartPoint = CGPoint(
			x: -screenSize.width,
			y: frame.minY + 50
		)
		let groundEndPoint = CGPoint(
			x: backgroundImageTwo.position.x + screenSize.width,
			y: frame.minY + 50
		)
		let groundBoundaryBody = SKPhysicsBody(edgeFrom: groundStartPoint, to: groundEndPoint)
		let groundBoundary = SKNode()
		groundBoundary.physicsBody = groundBoundaryBody
		addChild(groundBoundary)
	}

	
	override func update(_ currentTime: TimeInterval) {
		// Initialize _lastUpdateTime if it has not already been
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		// Calculate time since last update
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		let minX = frame.minX + hero.size.width / 2
		let maxX = backgroundImageTwo.position.x - hero.size.width / 2
		
		// Clamp hero's x-position within the bounds
		hero.position.x = min(maxX, max(minX, hero.position.x))
		
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
		
		// Calculate velocity based on the position of the joystick's stick
		let velocity = CGVector(
			dx: joystick.stick.position.x,
			dy: joystick.stick.position.y
		)
		
		// Check if the velocity magnitude is greater than zero
		if hypot(velocity.dx, velocity.dy) > 0 {
			// Determine the direction of movement
			let isMovingLeft = velocity.dx < 0
			
			// Update hero's facing direction
			hero.xScale = isMovingLeft ? -1 : 1
			
			if isRunning {
				// If the hero is moving and the running button is pressed, trigger the running animation
				hero.removeAction(forKey: hero.heroWalkingKey)
				hero.heroRunningAnimation()
			} else {
				// If the hero is moving but the running button is not pressed, trigger the walking animation
				hero.removeAction(forKey: hero.heroRunningKey)
				hero.heroWalkingAnimation()
			}
		} else {
			// If the hero is not moving, remove all animations
			hero.removeAllActions()
		}
		
		// Handle undead following hero
		let undeadToHeroDistance = hypot(hero.position.x - undead.position.x, hero.position.y - undead.position.y)
		
		if undeadToHeroDistance <= undead.senseRadius {
			let angle = atan2(hero.position.y - undead.position.y, hero.position.x - undead.position.x)
			let moveSpeed = undead.undeadSpeed * CGFloat(dt)
			let moveX = cos(angle) * moveSpeed
			let moveY = sin(angle) * moveSpeed
			
			// Update undead position
			undead.position = CGPoint(
				x: undead.position.x + moveX,
				y: undead.position.y + moveY
			)
			
			// Determine the direction of movement
			let isMovingLeft = moveX < 0
			
			// Update undead's facing direction
			undead.xScale = isMovingLeft ? -1 : 1
			
			undead.undeadWalkingAnimation()
		} else {
			// If the undead is not within sense radius, stop the animation
			undead.removeAllActions()
		}
	}
}
