//
//  TutorialScreen.swift
//  ForStayingAlive
//
//  Created by Filbert Chai on 26/06/24.
//

import Foundation
import SpriteKit

class TutorialScreen: SKScene {
    private var LockerTutorialLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    private var lockerSprite = LockerSprite.newInstance()
    
    private var ChestTutorialLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    private var chestSprite = ChestSprite.newInstance()
    
    private var NextLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    
    override func didMove(to view: SKView) {
        LockerTutorialLabel.text = "You Can Hide Inside the Locker"
        LockerTutorialLabel.fontSize = 25
        LockerTutorialLabel.position = CGPoint(x: frame.midX - 35, y: frame.midY + 55)
        addChild(LockerTutorialLabel)
        
        lockerSprite.position = CGPoint(x: frame.minX + 120, y: frame.midY + 70)
        addChild(lockerSprite)
        
        ChestTutorialLabel.text = "Collect MedKit on the Shelf"
        ChestTutorialLabel.fontSize = 25
        ChestTutorialLabel.position = CGPoint(x: frame.midX - 60, y: frame.midY - 80)
        addChild(ChestTutorialLabel)
        
        chestSprite.position = CGPoint(x: frame.minX + 120, y: frame.midY - 70)
        addChild(chestSprite)
        
        NextLabel.text = "Next"
        NextLabel.fontSize = 20
        NextLabel.position = CGPoint(x: frame.maxX - 100, y: frame.minY + 50)
        addChild(NextLabel)
        
    }
    
    func backgroundTapped() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = ExplorationMap(size: size)
        gameScene.scaleMode = scaleMode
        
        view?.presentScene(gameScene, transition: transition)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if (self.frame.contains(touch.location(in: self))) {
                backgroundTapped()
            }
        }
    }
}
