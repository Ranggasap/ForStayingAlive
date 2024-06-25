//
//  MainMenuScreen.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 25/06/24.
//

import Foundation
import SpriteKit

class MainMenuScreen: SKScene {
    private var mainMenuLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    
    private var startButtonLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    
    override func didMove(to view: SKView) {
        mainMenuLabel.text = "The Last Flight Out"
        mainMenuLabel.fontSize = 40
        mainMenuLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(mainMenuLabel)
        
        startButtonLabel.text = "Start"
        startButtonLabel.fontSize = 32
        startButtonLabel.position = CGPoint(x: frame.midX, y: 100)
        addChild(startButtonLabel)
        
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let scaleForever = SKAction.repeatForever(scaleSequence)
        startButtonLabel.run(scaleForever)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if startButtonLabel.contains(location){
                let explorationMap = ExplorationMap(size: self.size)
                explorationMap.scaleMode = .aspectFill
                let transition = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(explorationMap, transition: transition)
            }
        }
    }
}

