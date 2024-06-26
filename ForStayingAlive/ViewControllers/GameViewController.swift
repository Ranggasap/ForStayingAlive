//
//  GameViewController.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 03/06/24.
//

import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let sceneNode = MainMenuScreen(size: view.frame.size)
		
		if let view = self.view as! SKView? {
			view.presentScene(sceneNode)
			view.ignoresSiblingOrder = true
			
			view.showsFPS = true
			view.showsNodeCount = false
            view.showsPhysics = false
			
			view.preferredFramesPerSecond = 30
		}
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
}
