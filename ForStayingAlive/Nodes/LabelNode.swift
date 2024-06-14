//
//  LabelNode.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 14/06/24.
//

import Foundation
import SpriteKit

class LabelNode: SKNode{
    var node: SKLabelNode?
    
    convenience init(text: String, fontSize: CGFloat, fontColor: UIColor) {
        self.init()
        node = SKLabelNode(text: text)
        node?.fontSize = fontSize
        node?.fontColor = fontColor
        node?.fontName = "Helvetica-Bold"
        if let node = node{
            addChild(node)
        }
        
    }
}
