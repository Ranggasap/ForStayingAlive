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
		let hidingButton = HidingButton(imageNamed: "hide-button")
		hidingButton.size = CGSize(width: hidingButton.size.width, height: hidingButton.size.height)
		hidingButton.isUserInteractionEnabled = true
		hidingButton.isHidden = true
		
		return hidingButton
	}
	
	private func toggleHidingState() {
		if let hero = parent?.parent?.childNode(withName: "Hero") as? HeroSprite {
			isHeroHiding.toggle()
			hero.isHidden = isHeroHiding
			let hideButton = isHeroHiding ? "out-button" : "hide-button"
			self.texture = SKTexture(imageNamed: hideButton)
		}
	}
	
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		toggleHidingState()
	}
}
