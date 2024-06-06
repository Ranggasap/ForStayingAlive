//
//  PlayerSprite.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 06/06/24.
//

import Foundation
import SpriteKit

class PlayerSprite: SKSpriteNode{
    private var destination: CGPoint!
    private let easing: CGFloat = 0.1
    
    static func newInstance() -> PlayerSprite {
        let playerTexture = SKTexture(imageNamed: "player")
        
        let player = PlayerSprite(imageNamed: "player")
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        player.physicsBody?.isDynamic = false
        player.size = CGSize(width: player.size.width * 10, height: player.size.height * 10)
        
        
        return player
    }
    
    public func updatePosition(point: CGPoint){
        position = point
        destination = point
    }
    
    public func setDestination(destination: CGPoint){
        self.destination = destination
    }
    
    public func update(dateTime: TimeInterval){
        let distance = sqrt(pow((destination.x - position.x),2) + pow((destination.y - position.y), 2))
        
        if(distance > 1){
            let directionX = (destination.x - position.x)
            let directionY = (destination.y - position.y)
            
            position.x += directionX * easing
            position.y += directionY * easing
            
            let angle = atan2(directionY, directionX) - CGFloat.pi / 2
            zRotation = angle
        }else{
            position = destination
        }
    }
}
