//
//  NextFloorSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 20/06/24.
//

import SpriteKit

public class NextFloorSprite : SKSpriteNode {
	public static func newInstance() -> NextFloorSprite {
		let nextFloor = NextFloorSprite(color: .yellow, size: CGSize(width: 20, height: 20))
		nextFloor.zPosition = 1
		
		nextFloor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: nextFloor.size.width, height: nextFloor.size.height))
		nextFloor.physicsBody?.affectedByGravity = false
		nextFloor.physicsBody?.isDynamic = false
		nextFloor.physicsBody?.pinned = true
		
		nextFloor.physicsBody?.categoryBitMask = NextFloorCategory
		nextFloor.physicsBody?.contactTestBitMask = HeroCategory
		
		return nextFloor
	}
}
