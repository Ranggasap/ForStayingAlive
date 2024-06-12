//
//  HidingButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 11/06/24.
//

import SpriteKit

public class HidingButton : SKSpriteNode {
	public static func newInstance() -> HidingButton {
		let hidingButton = HidingButton(imageNamed: "locker")
		hidingButton.size = CGSize(width: hidingButton.size.width / 2, height: hidingButton.size.height / 2)
		hidingButton.isUserInteractionEnabled = true
		hidingButton.isHidden = true
		
		return hidingButton
	}
}
