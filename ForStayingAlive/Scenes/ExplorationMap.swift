//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit
import GameplayKit

class ExplorationMap : SKScene {
    var joystick: AnalogJoystick!
    var player: SKSpriteNode!
    
	private let hero = PlayerSprite.newInstance()
	
	override func didMove(to view: SKView) {
        // Set up the joystick with custom colors and size
        let joystickDiameter: CGFloat = min(size.width, size.height) * 0.2
        
        // Create the substrate with a gray border and white fill
        let substrate = AnalogJoystickSubstrate(diameter: joystickDiameter, borderColor: .gray, fillColor: .white)
        substrate.borderWidth = 10.0
        
        // Create the stick with gray color
        let stick = AnalogJoystickStick(diameter: joystickDiameter * 0.6, borderColor: .gray, fillColor: .gray)
        
        // Initialize the joystick
        joystick = AnalogJoystick(substrate: substrate, stick: stick)
        joystick.position = CGPoint(x: size.width * 0.1, y: size.height * 0.15) // Adjust the position here
        addChild(joystick)
        
        spawnPlayerHero()
        
        // Joystick tracking handler
        joystick.trackingHandler = { [unowned self] data in
            let velocity = data.velocity
            let moveSpeed: CGFloat = 0.12
            self.hero.position = CGPoint(
                x: self.hero.position.x + velocity.x * moveSpeed,
                y: self.hero.position.y + velocity.y * moveSpeed
            )
        }
        
		createBackground()
	}
	
	func spawnPlayerHero() {
		hero.position = CGPoint(x: frame.midX, y: frame.midY)
		addChild(hero)
	}
	
	func createBackground() {
		let screenSize = self.size
		let backgroundImage = SKSpriteNode(imageNamed: "sky")
		
		backgroundImage.size = CGSize(width: screenSize.width, height: screenSize.height / 2)
		backgroundImage.position = CGPoint(x: screenSize.width / 2, y: screenSize.height - backgroundImage.size.height / 2)
		backgroundImage.zPosition = 0
		
		let colorNode = SKSpriteNode(color: UIColor(named: "terrain-color") ?? .white, size: CGSize(width: screenSize.width, height: screenSize.height / 2))
		colorNode.position = CGPoint(x: screenSize.width / 2, y: colorNode.size.height / 2)
		
		addChild(backgroundImage)
		addChild(colorNode)
	}
}
