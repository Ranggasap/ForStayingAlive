//
//  HideButtonSprite.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 11/06/24.
//

import Foundation
import SpriteKit

class HideButtonSprite: SKSpriteNode{
    var hideButtonAction: (() -> ())?
    
    private var hideButtonTexture = SKTexture(imageNamed: "hideButton")
    private var outButtonTexture = SKTexture(imageNamed: "outButton")
    private var hideButton: SKSpriteNode!
    private(set) var hideButtonPressed = false
    
    func setup(){
        hideButton = SKSpriteNode(texture: hideButtonTexture)
        hideButton.zPosition = 1000
        addChild(hideButton)
    }
    
    func touchBeganAtPoint(point: CGPoint){
        hideButtonPressed = true
    }
    
    func touchMovedAtPoint(point: CGPoint){
        
    }
    
    func touchEndedAtPoint(point: CGPoint){
        hideButtonAction!()
        hideButtonPressed = false
    }
    
    func hideButtonChange(){
        if (hideButton.texture == outButtonTexture){
            hideButton.texture = hideButtonTexture
        }else{
            hideButton.texture = outButtonTexture
        }
    }
}
