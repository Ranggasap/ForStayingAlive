//
//  MedkitButton.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 15/06/24.
//

import SpriteKit

public class MedkitButton : SKSpriteNode {
	private var numberOfMedkit = 0
	private var medkitCountLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
	
	public static func newInstance() -> MedkitButton {
		let medkitButton = MedkitButton(imageNamed: "medkit")
		medkitButton.size = CGSize(width: medkitButton.size.width / 2 + 10, height: medkitButton.size.height / 2 + 10)
		medkitButton.isUserInteractionEnabled = true
		medkitButton.numberOfMedkitLabel()
		
		return medkitButton
	}
	
	private func numberOfMedkitLabel() {
		medkitCountLabel.text = "\(numberOfMedkit)"
		medkitCountLabel.fontColor = .white
		medkitCountLabel.fontSize = 14
		medkitCountLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 55)
		addChild(medkitCountLabel)
	}
	
	public func getMedkitCount() -> Int {
		return numberOfMedkit
	}
	
	public func addMedkitCount() {
		numberOfMedkit += 1
		
		if numberOfMedkit > 3 {
			numberOfMedkit = 3
		}
		
		medkitCountLabel.text = "\(numberOfMedkit)"
		checkMedkitAvailability()
	}
	
	public func reduceMedkitCount() {
		numberOfMedkit -= 1
		
		if numberOfMedkit < 0 {
			numberOfMedkit = 0
		}
		
		medkitCountLabel.text = "\(numberOfMedkit)"
		checkMedkitAvailability()
	}
	
	private func checkMedkitAvailability() {
		self.isUserInteractionEnabled = numberOfMedkit > 0
	}
	
	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if numberOfMedkit > 0, let parentScene = self.scene as? ExplorationMap {
			parentScene.heroUseMedkit()
			reduceMedkitCount()
		}
	}
}
