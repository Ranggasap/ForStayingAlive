//
//  HidingButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 11/06/24.
//

import SpriteKit

public class HidingButton : SKSpriteNode {
	private var isHeroHiding = false
	
	public static func newInstance() -> HidingButton {
		let hidingButton = HidingButton(imageNamed: "hero-hide-button")
		hidingButton.size = CGSize(width: hidingButton.size.width / 2, height: hidingButton.size.height / 2)
		hidingButton.isUserInteractionEnabled = true
		hidingButton.isHidden = true
		
		return hidingButton
	}
	
	private func toggleHidingState() {
		if let hero = parent?.parent?.childNode(withName: "Hero") as? HeroSprite {
			isHeroHiding.toggle()
			hero.isHidden = isHeroHiding
			let hideButton = isHeroHiding ? "hero-out-button" : "hero-hide-button"
			self.texture = SKTexture(imageNamed: hideButton)
		}
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		toggleHidingState()
		let buttonPressed = SKAction.scale(to: 0.9, duration: 0.2)
		self.run(buttonPressed)
		
		let lockerSlam = SKAction.playSoundFileNamed("locker-slam", waitForCompletion: false)
		self.run(lockerSlam)
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let buttonReleased = SKAction.scale(to: 1.0, duration: 0.2)
		self.run(buttonReleased)
		
		let lockerSlam = SKAction.playSoundFileNamed("locker-slam", waitForCompletion: false)
		self.run(lockerSlam)
	}
	
	public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		let buttonReleased = SKAction.scale(to: 1.0, duration: 0.2)
		self.run(buttonReleased)
		
		let lockerSlam = SKAction.playSoundFileNamed("locker-slam", waitForCompletion: false)
		self.run(lockerSlam)
	}
}
