//
//  NextSceneNode.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 14/06/24.
//

import Foundation
import SpriteKit

class NextSceneNode: SKNode{
    var nextSceneBar: SKSpriteNode!
    
    convenience init(size: CGSize) {
        self.init()
        nextSceneBar = SKSpriteNode(color: .yellow, size: size)
        nextSceneBar.zPosition = 3
        nextSceneBar.physicsBody = SKPhysicsBody(rectangleOf: size)
        nextSceneBar.physicsBody?.affectedByGravity = false
        nextSceneBar.physicsBody?.categoryBitMask = NextSceneCategory
        nextSceneBar.physicsBody?.contactTestBitMask = HeroCategory
        nextSceneBar.physicsBody?.pinned = true
        nextSceneBar.physicsBody?.isDynamic = false
        addChild(nextSceneBar)
    }
}
