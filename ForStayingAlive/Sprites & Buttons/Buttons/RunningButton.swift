//
//  RunningButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 08/06/24.
//

import SpriteKit

public class RunningButton : SKSpriteNode {
	private(set) var isRunningButtonPressed = false
	
	var onPress: (() -> Void)?
	var onRelease: (() -> Void)?
	
	public static func newInstance() -> RunningButton {
		let runningButton = RunningButton(imageNamed: "run-button")
		runningButton.size = CGSize(width: runningButton.size.width / 2 + 20, height: runningButton.size.height / 2 + 20)
		runningButton.isUserInteractionEnabled = true
		
		return runningButton
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		isRunningButtonPressed = true
		onPress?()
		let runningButtonPressed = SKAction.scale(to: 0.9, duration: 0.2)
		self.run(runningButtonPressed)
	}
	
	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		isRunningButtonPressed = false
		onRelease?()
		let runningButtonReleased = SKAction.scale(to: 1.0, duration: 0.2)
		self.run(runningButtonReleased)
	}
	
	public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		isRunningButtonPressed = false
		onRelease?()
		let runningButtonReleased = SKAction.scale(to: 1.0, duration: 0.5)
		self.run(runningButtonReleased)
	}
}
