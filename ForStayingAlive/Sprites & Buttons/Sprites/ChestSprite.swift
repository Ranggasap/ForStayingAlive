//
//  ChestSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 11/06/24.
//

import SpriteKit

public class ChestSprite : SKSpriteNode {
	public static func newInstance() -> ChestSprite {
		let chestSprite = ChestSprite(imageNamed: "chest")
		chestSprite.size = CGSize(width: chestSprite.size.width, height: chestSprite.size.height)
		chestSprite.zPosition = 1
		
		chestSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: chestSprite.size.width / 2, height: chestSprite.size.height / 2))
		chestSprite.physicsBody?.affectedByGravity = false
		chestSprite.physicsBody?.allowsRotation = false
		chestSprite.physicsBody?.pinned = true
		
		chestSprite.physicsBody?.categoryBitMask = ChestCategory
		chestSprite.physicsBody?.contactTestBitMask = HeroCategory
		chestSprite.physicsBody?.collisionBitMask = HeroCategory | UndeadCategory
		
		return chestSprite
	}
}
