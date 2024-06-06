//
//  GameScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 03/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var lastUpdateTime: TimeInterval = 0
    
    private let player = PlayerSprite.newInstance()
    
    override func sceneDidLoad() {
        player.updatePosition(point: CGPoint(x: frame.midX, y: frame.midY))
        addChild(player)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint{
            player.setDestination(destination: point)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint{
            player.setDestination(destination: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if(self.lastUpdateTime == 0){
            self.lastUpdateTime = currentTime
        }
        
        let dt = currentTime - self.lastUpdateTime
        
        player.update(dateTime: dt)
        
        self.lastUpdateTime = currentTime
    }
}
