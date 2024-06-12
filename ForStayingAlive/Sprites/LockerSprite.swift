//
//  LockerSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 12/06/24.
//

import SpriteKit

public class LockerSprite : SKSpriteNode {
	public static func newInstance() -> LockerSprite {
		let lockerSprite = LockerSprite(imageNamed: "locker")
		lockerSprite.size = CGSize(width: lockerSprite.size.width, height: lockerSprite.size.height)
		lockerSprite.zPosition = 1
		
		lockerSprite.physicsBody = SKPhysicsBody(rectangleOf: lockerSprite.size)
		lockerSprite.physicsBody?.affectedByGravity = false
		lockerSprite.physicsBody?.allowsRotation = false
		lockerSprite.physicsBody?.pinned = true
		
		lockerSprite.physicsBody?.categoryBitMask = LockerCategory
		lockerSprite.physicsBody?.contactTestBitMask = HeroCategory
		
		return lockerSprite
	}
}
