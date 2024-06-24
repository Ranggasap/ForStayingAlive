//
//  HelicopterSprite.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 24/06/24.
//

import Foundation
import SpriteKit

public class HelicopterSprite: SKSpriteNode {
    public static func newInstance() -> HelicopterSprite{
        
        let helicopterSprite = HelicopterSprite(imageNamed: "helicopterSprite")
        helicopterSprite.size = CGSize(width: helicopterSprite.size.width, height: helicopterSprite.size.height)
        helicopterSprite.zPosition = 1
        
        return helicopterSprite
    }
}
