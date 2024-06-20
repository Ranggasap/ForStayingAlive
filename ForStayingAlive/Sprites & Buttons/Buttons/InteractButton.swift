//
//  InteractButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 11/06/24.
//

import SpriteKit

public class InteractButton : SKSpriteNode {
	private var medkitButton: MedkitButton!
	
	public static func newInstance() -> InteractButton {
		let interactButton = InteractButton(imageNamed: "loot-medkit-button")
		interactButton.size = CGSize(width: interactButton.size.width / 2.5, height: interactButton.size.height / 2.5)
		interactButton.isUserInteractionEnabled = true
		interactButton.isHidden = true
		
		return interactButton
	}
	
	public func setMedkitButton(_ medkitButton: MedkitButton) {
		self.medkitButton = medkitButton
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		medkitButton.addMedkitCount()
	}
}
