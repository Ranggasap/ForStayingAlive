//
//  PlayerSprite.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 06/06/24.
//

import SpriteKit

public class PlayerSprite : SKSpriteNode {
	public static func newInstance() -> PlayerSprite {
		let playerHero = PlayerSprite(imageNamed: "player-test-normal")
		playerHero.size = CGSize(width: playerHero.size.width, height: playerHero.size.height)
		playerHero.zPosition = 1
		
		// Add physics body for hero here
		// Code...
		
		return playerHero
	}
	
	// Frames for running animation
	private let runningFrames: [SKTexture] = (0...7).map { i in
		SKTexture(imageNamed: "player-test-run\(i)")
	}
}
