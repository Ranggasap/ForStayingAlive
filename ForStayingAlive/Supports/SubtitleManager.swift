//
//  SubtitleManager.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 21/06/24.
//

import Foundation
import SpriteKit

class SubtitleManager {
    private var subtitleLabel: SKLabelNode
    private var subtitleQueue: [(text: String, duration: TimeInterval)] = []
    private var isDisplaying: Bool = false
    
    init(parentNode: SKNode, fontName: String = "NicoClean-Regular", fontSize: CGFloat = 18, fontColor: SKColor = .white) {
        subtitleLabel = SKLabelNode()
        subtitleLabel.fontName = fontName
        subtitleLabel.fontSize = fontSize
        subtitleLabel.fontColor = fontColor
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.zPosition = 10
        parentNode.addChild(subtitleLabel)
    }
    
    func updateSubtitle(_ text: String, duration: TimeInterval){
        subtitleQueue.append((text, duration))
        if !isDisplaying{
            displayNextSubtitle()
        }
    }
    
    private func displayNextSubtitle(){
        guard !subtitleQueue.isEmpty else {
            isDisplaying = false
            return
        }
        
        isDisplaying = true
        let nextSubtitle = subtitleQueue.removeFirst()
        subtitleLabel.text = nextSubtitle.text
        
        let waitAction = SKAction.wait(forDuration: nextSubtitle.duration)
        let clearAction = SKAction.run { [weak self] in
            self?.subtitleLabel.text = ""
        }
        
        let sequence = SKAction.sequence([waitAction, clearAction])
        
        subtitleLabel.run(sequence){ [weak self] in
            self?.isDisplaying = false
            self?.displayNextSubtitle()
        }
    }
    
    func setPosition(xPoint x: CGFloat, yPoint y: CGFloat){
        subtitleLabel.position = CGPoint(x: x, y: y)
    }
}
