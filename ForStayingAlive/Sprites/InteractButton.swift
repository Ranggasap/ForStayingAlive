//
//  InteractButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 11/06/24.
//

import SpriteKit

public class InteractButton : SKSpriteNode {
	public static func newInstance() -> InteractButton {
		let interactButton = InteractButton(imageNamed: "chest")
		interactButton.size = CGSize(width: interactButton.size.width / 2 + 20, height: interactButton.size.height / 2 + 20)
		interactButton.isUserInteractionEnabled = true
		interactButton.isHidden = true
		
		return interactButton
	}
}
