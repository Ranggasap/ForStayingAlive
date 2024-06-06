//
//  UndeadSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit

public class UndeadSprite : SKSpriteNode {
	public static func newInstance() -> UndeadSprite {
		let undeadSprite = UndeadSprite(imageNamed: "undead")
		undeadSprite.size = CGSize(width: undeadSprite.size.width * 5, height: undeadSprite.size.width * 5)
		undeadSprite.zPosition = 1
		
		undeadSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: undeadSprite.size.width, height: undeadSprite.size.height))
		undeadSprite.physicsBody?.allowsRotation = false
		undeadSprite.physicsBody?.pinned = true
		
		undeadSprite.physicsBody?.categoryBitMask = UndeadCategory
		
		return undeadSprite
	}
	
	private func undeadSense() {
		
	}
}
