//
//  RunningButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 08/06/24.
//

import SpriteKit

public class RunningButton : SKSpriteNode {
	public static func newInstance() -> RunningButton {
		let runningButton = RunningButton(imageNamed: "player-test-run0")
		runningButton.size = CGSize(width: runningButton.size.width * 1.5, height: runningButton.size.height * 1.5)
		
		return runningButton
	}
}
