//
//  LockerSprite.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 10/06/24.
//

import Foundation
import SpriteKit

public class LockerSprite: SKSpriteNode{
    public static func newInstance() -> LockerSprite{
        let locker = LockerSprite(imageNamed: "locker")
        
        locker.physicsBody = SKPhysicsBody(rectangleOf: locker.size)
        locker.physicsBody?.categoryBitMask = LockerCategory
        locker.physicsBody?.contactTestBitMask = HeroCategory
        locker.physicsBody?.affectedByGravity = false
        locker.physicsBody?.isDynamic = false
        locker.zPosition = 3
        
        return locker
    }
}
