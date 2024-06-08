//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap: SKScene {
	private let hero = PlayerSprite.newInstance()
	private let runningButton = RunningButton.newInstance()
	private let heroCamera = SKCameraNode()
	
	private var joystick: AnalogJoystick!
	private var joystickOverlay = SKNode()
	
	private var backgroundImageOne: SKSpriteNode!
	private var backgroundImageTwo: SKSpriteNode!
	
	override func didMove(to view: SKView) {
		createBackground()
		createBoundary()
		addPlayerHero()
		setupCamera()
		addJoystick()
		addRunningButton()
	}
	
	func addPlayerHero() {
		hero.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(hero)
	}

	func addJoystick() {
		let joystickDiameter: CGFloat = min(size.width, size.height) * 0.2
		
		let substrate = AnalogJoystickSubstrate(diameter: joystickDiameter, borderColor: .gray, fillColor: .white)
		substrate.borderWidth = 10.0
		
		let stick = AnalogJoystickStick(diameter: joystickDiameter * 0.6, borderColor: .gray, fillColor: .gray)
		
		joystick = AnalogJoystick(substrate: substrate, stick: stick)
		joystick.position = CGPoint(x: 0, y: 0)
		joystick.zPosition = 10
		
		joystickOverlay.addChild(joystick)
		
		joystick.trackingHandler = { [unowned self] data in
			let velocity = data.velocity
			let moveSpeed: CGFloat = 0.2
			self.hero.position = CGPoint(
				x: self.hero.position.x + velocity.x * moveSpeed,
				y: self.hero.position.y + velocity.y * moveSpeed
			)
		}
	}
	
	func addRunningButton() {
		runningButton.position = CGPoint(x: size.width / 2 - runningButton.size.width / 2 - 70,
										 y: -size.height / 2 + runningButton.size.height / 2 + 70)
		runningButton.zPosition = 10
	}
	
	func setupCamera() {
		camera = heroCamera
		heroCamera.position = CGPoint(x: hero.position.x, y: size.height / 2)
		addChild(heroCamera)
		
		heroCamera.addChild(joystickOverlay)
		heroCamera.addChild(runningButton)
	}
	
	func createBackground() {
		let screenSize = self.size
		
		backgroundImageOne = SKSpriteNode(imageNamed: "background")
		
		backgroundImageOne.size = CGSize(width: screenSize.width, height: screenSize.height)
		backgroundImageOne.position = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
		backgroundImageOne.zPosition = 0
		addChild(backgroundImageOne)
		
		// Create flipped background image
		backgroundImageTwo = SKSpriteNode(imageNamed: "background")
		backgroundImageTwo.size = backgroundImageOne.size
		
		// Calculate the position for backgroundImageTwo
		let backgroundImageTwoX = backgroundImageOne.position.x + (backgroundImageOne.size.width / 2) + (backgroundImageTwo.size.width / 2)
		let backgroundImageTwoY = screenSize.height / 2
		
		backgroundImageTwo.position = CGPoint(x: backgroundImageTwoX, y: backgroundImageTwoY)
		backgroundImageTwo.zPosition = 0
		backgroundImageTwo.xScale = -1 // Flip horizontally
		addChild(backgroundImageTwo)
	}


	func createBoundary() {
		let screenSize = self.size
		
		// Horizon Boundary
		let horizonStartPoint = CGPoint(x: -screenSize.width, y: frame.midY + 100)
		let horizonEndPoint = CGPoint(x: backgroundImageTwo.position.x + screenSize.width, y: frame.midY + 100) // Adjusted endpoint
		let horizonBoundaryBody = SKPhysicsBody(edgeFrom: horizonStartPoint, to: horizonEndPoint)
		let horizonBoundary = SKNode()
		horizonBoundary.physicsBody = horizonBoundaryBody
		addChild(horizonBoundary)
		
		// Ground Boundary
		let groundStartPoint = CGPoint(x: -screenSize.width, y: frame.minY + 50)
		let groundEndPoint = CGPoint(x: backgroundImageTwo.position.x + screenSize.width, y: frame.minY + 50) // Adjusted endpoint
		let groundBoundaryBody = SKPhysicsBody(edgeFrom: groundStartPoint, to: groundEndPoint)
		let groundBoundary = SKNode()
		groundBoundary.physicsBody = groundBoundaryBody
		addChild(groundBoundary)
	}

	
	override func update(_ currentTime: TimeInterval) {
		let minX = frame.minX + hero.size.width / 2
		let maxX = backgroundImageTwo.position.x - hero.size.width / 2 // Right bound of backgroundImageTwo
		
		// Clamp hero's x-position within the bounds
		hero.position.x = min(maxX, max(minX, hero.position.x))
		
		// Update the camera position to follow the hero horizontally within bounds
		let cameraX = max(hero.position.x, size.width / 2)
		let maxCameraX = backgroundImageTwo.position.x - size.width / 2 // Right bound of backgroundImageTwo
		heroCamera.position.x = min(maxCameraX, cameraX)
		
		// Keep the overlay node fixed relative to the camera
		let joystickPosX = -size.width / 2 + joystick.frame.width / 2 + 150
		let joystickPosY = -size.height / 2 + joystick.frame.height / 2 + 100
		joystick.position = CGPoint(x: joystickPosX, y: joystickPosY)
				
		// Calculate velocity based on the position of the joystick's stick
		let velocity = CGVector(dx: joystick.stick.position.x, dy: joystick.stick.position.y)
		
		// Check if the velocity magnitude is greater than zero
		if hypot(velocity.dx, velocity.dy) > 0 {
			// If the hero is moving, trigger the running animation
			hero.walkingAnimation()
			
			// Determine the direction of movement
			let isMovingLeft = velocity.dx < 0
			
			// Update hero's facing direction
			hero.xScale = isMovingLeft ? -1 : 1
		} else {
			// If the hero is not moving, remove the running animation
			hero.removeAction(forKey: hero.walkingAnimationKey)
		}
	}
}
