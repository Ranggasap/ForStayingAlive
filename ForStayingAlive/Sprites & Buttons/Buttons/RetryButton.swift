//
//  RetryButton.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 24/06/24.
//

import Foundation
import SpriteKit

class RetryButton: SKSpriteNode {
    public static func newInstance() -> RetryButton {
        let retryButton = RetryButton(imageNamed: "retry-button")
        retryButton.size = CGSize(width: retryButton.size.width * 0.5, height: retryButton.size.height * 0.5)
        retryButton.isUserInteractionEnabled = true
        return retryButton
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
