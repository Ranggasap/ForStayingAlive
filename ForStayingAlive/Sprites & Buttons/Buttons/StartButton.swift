//
//  StartButton.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 25/06/24.
//

import Foundation
import SpriteKit

class StartButton: SKSpriteNode {
    public static func newInstance() -> StartButton {
        let startButton = StartButton(imageNamed: "startButton")
        startButton.size = CGSize(width: startButton.size.width * 0.5, height: startButton.size.height * 0.5)
        startButton.isUserInteractionEnabled = true
        return startButton
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 0.7  // Berikan efek visual ketika tombol disentuh
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 1.0
        
        guard let view = self.scene?.view else { return }
        let transition = SKTransition.fade(withDuration: 1.0)
        let explorationScene = ExplorationMap(size: view.bounds.size)
        explorationScene.scaleMode = .aspectFill
        view.presentScene(explorationScene, transition: transition)
    }
}
