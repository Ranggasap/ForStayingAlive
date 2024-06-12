//
//  RunningButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 08/06/24.
//

import SpriteKit

public class RunningButton : SKSpriteNode {
	private(set) var isRunningButtonPressed = false
	
	public static func newInstance() -> RunningButton {
		let runningButton = RunningButton(imageNamed: "player-test-run0")
		runningButton.size = CGSize(width: runningButton.size.width * 1.5, height: runningButton.size.height * 1.5)
		runningButton.isUserInteractionEnabled = true
		
		return runningButton
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		isRunningButtonPressed = true
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		isRunningButtonPressed = false
	}
}
