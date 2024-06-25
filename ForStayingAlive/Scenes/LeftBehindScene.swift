//
//  GameOverScene.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 15/06/24.
//

import Foundation
import SpriteKit

class LeftBehindScene: SKScene{
    private let leftBehindLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
    private var subtitleManager: SubtitleManager!
    private let retryButton = RetryButton.newInstance()
	private let hero = HeroSprite.newInstance()
	private let undeadOne = UndeadSprite.newInstance()
	private let undeadTwo = UndeadSprite.newInstance()
    
    override func sceneDidLoad() {
        leftBehindLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 50)
        leftBehindLabel.text = "You have been left behind..."
        leftBehindLabel.fontSize = 40
        leftBehindLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        addChild(leftBehindLabel)
		
		hero.position = CGPoint(x: frame.midX + 100, y: frame.midY - 50)
		hero.size = CGSize(width: hero.size.width * 2, height: hero.size.height * 2)
		addChild(hero)
		hero.heroRunningAnimation()
		
		undeadOne.position = CGPoint(x: frame.midX - 50, y: frame.midY - 50)
		undeadOne.size = CGSize(width: undeadOne.size.width * 2, height: undeadOne.size.height * 2)
		addChild(undeadOne)
		undeadOne.undeadAttackingAnimation()
		
		undeadTwo.position = CGPoint(x: frame.midX - 120, y: frame.midY - 50)
		undeadTwo.size = CGSize(width: undeadTwo.size.width * 2, height: undeadTwo.size.height * 2)
		addChild(undeadTwo)
		undeadTwo.undeadAttackingAnimation()
        
        subtitleManager = SubtitleManager(parentNode: self)
        subtitleManager.setPosition(xPoint: frame.midX, yPoint: 0 + 50)
        
        SFXManager.shared.playSFX(name: "HelicopterTakeOff", type: "wav")
        subtitleManager.updateSubtitle("The helicopter is taking off now", duration: 3.0)
        subtitleManager.updateSubtitle("For survivors who are not evacuated", duration: 2)
        subtitleManager.updateSubtitle("Await government's radio signals", duration: 1.3)
        subtitleManager.updateSubtitle("For the next evacuation spot", duration: 1.5)
        subtitleManager.updateSubtitle("Take care of yourselves", duration: 1.5)
        
        retryButton.position = CGPoint(x: frame.maxX - 100, y: frame.minY / 2 + 50)
        addChild(retryButton)
    }
}
