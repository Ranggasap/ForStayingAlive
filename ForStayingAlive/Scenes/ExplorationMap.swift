//
//  ExplorationMap.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 11/06/24.
//

import SpriteKit
import GameplayKit
import AVFoundation
import Combine

class ExplorationMap: SKScene, SKPhysicsContactDelegate {
	private let hero = HeroSprite.newInstance()
	private let undead = UndeadSprite.newInstance()
	private let chestOne = ChestSprite.newInstance()
	private let chestTwo = ChestSprite.newInstance()
	private let lockerOne = LockerSprite.newInstance()
	private let lockerTwo = LockerSprite.newInstance()
	private let nextFloor = NextFloorSprite.newInstance()
	
	private let runningButton = RunningButton.newInstance()
	private let medkitButton = MedkitButton.newInstance()
	private let interactButton = InteractButton.newInstance()
	private let hidingButton = HidingButton.newInstance()
	
	private let healthBar = ProgressBarNode(color: .red, size: CGSize(width: 100, height: 10))
	private let staminaBar = ProgressBarNode(color: .green, size: CGSize(width: 100, height: 10))
	
	private var heroIsAttacked = false
	private var heroHealthReductionTimer: Timer?
	
	private var heroStaminaReductionTimer: Timer?
	private var heroStaminaRecoveryTimer: Timer?
	
	private let heroCamera = SKCameraNode()
	
	private var joystick: AnalogJoystick!
		
	private var hospitalGround: SKSpriteNode!
	private var hospitalBoundary: SKSpriteNode!
	
	private var lastUpdateTime: TimeInterval = 0
	
	private var backgroundTrack: AVAudioPlayer?
	private var helicopterTrack: AVAudioPlayer?
	
	private var countdownManager: CountdownManager?
	private var cancellables: Set<AnyCancellable> = []
	private var countdownLabel: SKLabelNode!
	
	private var subtitleManager: SubtitleManager!
	
	private var maskNode: SKShapeNode!
	private var darkOverlay: SKSpriteNode!
	private var cropNode: SKCropNode!
	
	override func didMove(to view: SKView) {
		physicsWorld.contactDelegate = self
		
		setupHeroCamera()
		
		addBackground()
		addJoystick()
		addRunningButton()
		addInteractButton()
		addHidingButton()
		addMedkitButton()
		addStatusBar()
		
		addVisibilityEffect()
		addBackgroundMusic()
		addCountdown()
		addPrologue()
		addObjective()
		
		spawnHero()
		spawnUndead()
		spawnChest()
		spawnLocker()
		spawnNextFloor()
		
		updateMedkitButtonState()
		
		undead.onHeroEnterAttackRange = { [weak self] in
			self?.startReducingHeroHealth()
		}
		undead.onHeroExitAttackRange = { [weak self] in
			self?.stopReducingHeroHealth()
		}
		
		runningButton.onPress = { [weak self] in
			guard let self = self else { return }
			if self.hero.getHeroStamina() > 0 {
				self.startStaminaReductionTimer()
				self.stopStaminaRecoveryTimer()
			}
		}
		
		runningButton.onRelease = { [weak self] in
			guard let self = self else { return }
			if self.heroStaminaRecoveryTimer == nil {
				self.stopStaminaReductionTimer()
				self.startStaminaRecoveryTimer()
			}
		}
	}
	
	override func willMove(from view: SKView) {
		backgroundTrack?.stop()
		helicopterTrack?.stop()
	}
	
	func addBackgroundMusic() {
		backgroundTrack = SoundManager.sharedInstance.startPlaying(soundName: "the-hired", fileExtension: "m4a")
		backgroundTrack?.volume = 0.8
		
		helicopterTrack = SoundManager.sharedInstance.startPlaying(soundName: "helicopter", fileExtension: "m4a")
		helicopterTrack?.volume = 0.6
	}
	
	func addVisibilityEffect() {
		darkOverlay = SKSpriteNode(color: .black, size: CGSize(width: hospitalGround.size.width, height: hospitalGround.size.height))
		darkOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
		darkOverlay.alpha = 0.9
		darkOverlay.zPosition = 5
		darkOverlay.isUserInteractionEnabled = false
		
		let maskRadius: CGFloat = 80.0
		let maskSize = CGSize(width: hospitalGround.size.width, height: hospitalGround.size.height)
		
		let maskPath = CGMutablePath()
		maskPath.addRect(CGRect(origin: .zero, size: maskSize))
		maskPath.addArc(center: CGPoint(x: maskSize.width / 2, y: maskSize.height / 2), radius: maskRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
		
		maskNode = SKShapeNode(path: maskPath)
		maskNode.fillColor = .black
		maskNode.strokeColor = .clear
		maskNode.lineWidth = 0
		maskNode.isUserInteractionEnabled = false
		
		cropNode = SKCropNode()
		cropNode.maskNode = maskNode
		cropNode.addChild(darkOverlay)
		cropNode.zPosition = 4
		cropNode.isUserInteractionEnabled = false
		addChild(cropNode)
	}
	
	func addCountdown() {
		countdownLabel = SKLabelNode(text: "")
		countdownLabel.fontSize = 40
		countdownLabel.fontName = "NicoClean-Regular"
		countdownLabel.position = CGPoint(x: -size.width / 2 + size.width / 2, y: size.height / 2 - 55)
		countdownLabel.zPosition = 10
		heroCamera.addChild(countdownLabel)
	}
	
	func addPrologue() {
		subtitleManager = SubtitleManager(parentNode: heroCamera)
		subtitleManager.setPosition(xPoint: 0, yPoint: -140)
		subtitleManager.updateSubtitle("Attention all survivors", duration: 1.2)
		subtitleManager.updateSubtitle("The helicopter takes off in 5 minutes", duration: 2.5)
		subtitleManager.updateSubtitle("Get to the rooftop now", duration: 1.25)
		subtitleManager.updateSubtitle("We repeat", duration: 0.75)
		subtitleManager.updateSubtitle("Get to the rooftop now", duration: 1.5)
		SFXManager.shared.playSFX(name: "HelicopterProlog", type: "m4a"){
			self.countdownManager = CountdownManager(totalTime: 300)
			
			self.countdownManager?.$displayTime.receive(on: RunLoop.main).sink{ [weak self] newTime in
				self?.countdownLabel.text = newTime
			}.store(in: &self.cancellables)
		}
	}
	
	func addObjective() {
		let objectiveLabel = SKLabelNode(fontNamed: "NicoClean-Regular")
		objectiveLabel.text = "Find the staircase to the rooftop!"
		objectiveLabel.fontSize = 14
		objectiveLabel.position = CGPoint(x: runningButton.position.x, y: countdownLabel.position.y + 10)
		objectiveLabel.zPosition = 10
		heroCamera.addChild(objectiveLabel)
	}
	
	func addBackground() {
		hospitalGround = SKSpriteNode(imageNamed: "hospital-ground")
		hospitalGround.size = CGSize(width: hospitalGround.size.width, height: hospitalGround.size.height)
		hospitalGround.position = CGPoint(x: frame.midX, y: frame.midY)
		hospitalGround.zPosition = -4
		addChild(hospitalGround)
		
		hospitalBoundary = SKSpriteNode(imageNamed: "hospital-boundary")
		hospitalBoundary.size = CGSize(width: hospitalBoundary.size.width, height: hospitalBoundary.size.height)
		hospitalBoundary.position = CGPoint(x: frame.midX, y: frame.midY)
		hospitalBoundary.zPosition = -5
				
		let boundaryTexture = hospitalBoundary.texture
		hospitalBoundary.physicsBody = SKPhysicsBody(texture: boundaryTexture!, size: hospitalBoundary.size)
		hospitalBoundary.physicsBody?.affectedByGravity = false
		hospitalBoundary.physicsBody?.isDynamic = false
		addChild(hospitalBoundary)
	}
	
	func addJoystick() {
		let joystickDiameter: CGFloat = min(size.width, size.height) * 0.2
		
		let substrate = AnalogJoystickSubstrate(diameter: joystickDiameter, borderColor: .gray, fillColor: .white)
		substrate.borderWidth = 10.0
		
		let stick = AnalogJoystickStick(diameter: joystickDiameter * 0.6, borderColor: .gray, fillColor: .gray)
		
		joystick = AnalogJoystick(substrate: substrate, stick: stick)
		joystick.position = CGPoint(x: -size.width / 2 + 150, y: -size.height / 2 + 100)
		joystick.zPosition = 10
		
		heroCamera.addChild(joystick)
		
		joystick.trackingHandler = { [weak self] data in
			guard let self = self else { return }
			
			let velocity = data.velocity
			let moveSpeed: CGFloat = self.runningButton.isRunningButtonPressed && hero.getHeroStamina() > 0 ? 0.35 : 0.2
			self.hero.position = CGPoint(x: self.hero.position.x + velocity.x * moveSpeed, y: self.hero.position.y + velocity.y * moveSpeed)
		}
	}
	
	func addRunningButton() {
		runningButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 100)
		runningButton.zPosition = 10
		heroCamera.addChild(runningButton)
	}
	
	func addInteractButton() {
		interactButton.position = CGPoint(x: runningButton.position.x, y: runningButton.position.y + 80)
		interactButton.zPosition = 10
		interactButton.setMedkitButton(medkitButton)
		heroCamera.addChild(interactButton)
	}
	
	func addHidingButton() {
		hidingButton.position = CGPoint(x: runningButton.position.x, y: runningButton.position.y + 80)
		hidingButton.zPosition = 10
		heroCamera.addChild(hidingButton)
	}
	
	func addMedkitButton() {
		medkitButton.position = CGPoint(x: runningButton.position.x - 90, y: runningButton.position.y + 10)
		medkitButton.zPosition = 10
		heroCamera.addChild(medkitButton)
	}
	
	func updateMedkitButtonState() {
		medkitButton.isUserInteractionEnabled = hero.getHeroHealth() < 100 && medkitButton.getMedkitCount() > 0
	}
	
	func addStatusBar() {
		healthBar.position = CGPoint(x: joystick.position.x, y: size.height / 2 - 30)
		healthBar.zPosition = 10
		heroCamera.addChild(healthBar)
		
		staminaBar.position = CGPoint(x: joystick.position.x, y: size.height / 2 - 45)
		staminaBar.zPosition = 10
		heroCamera.addChild(staminaBar)
	}
	
	func setupHeroCamera() {
		camera = heroCamera
		heroCamera.position = CGPoint(x: size.width / 2, y: size.height / 2)
		addChild(heroCamera)
	}
	
	func spawnHero() {
		hero.position = CGPoint(x: frame.midX - 100, y: frame.midY)
		hero.name = "Hero"
		addChild(hero)
	}
	
	func spawnUndead() {
		undead.position = CGPoint(x: frame.midX + 300, y: frame.midY)
		undead.setUndeadSpawnPosition()
		addChild(undead)
	}
	
	func spawnChest() {
		chestOne.position = CGPoint(x: frame.midX, y: frame.midY - 100)
		addChild(chestOne)
		
		chestTwo.position = CGPoint(x: frame.minX + 20, y: frame.midY - 100)
		addChild(chestTwo)
	}
	
	func spawnLocker() {
		lockerOne.position = CGPoint(x: frame.minX + 100, y: frame.midY)
		addChild(lockerOne)
		
		lockerTwo.position = CGPoint(x: frame.midX, y: frame.minY - 100)
		addChild(lockerTwo)
	}
	
	func spawnNextFloor() {
		nextFloor.position = CGPoint(x: frame.midX, y: frame.midY - 400)
		addChild(nextFloor)
	}
	
	func startHealthReductionTimer() {
		heroHealthReductionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(reduceHeroHealth), userInfo: nil, repeats: true)
	}
	
	func stopHealthReductionTimer() {
		heroHealthReductionTimer?.invalidate()
		heroHealthReductionTimer = nil
	}
	
	@objc func reduceHeroHealth() {
		hero.heroHealthReduced(health: 10)
		healthBar.update(progress: hero.getHeroHealth() / 100.0)
		updateMedkitButtonState()
	}
	
	func startReducingHeroHealth() {
		if !heroIsAttacked {
			heroIsAttacked = true
			startHealthReductionTimer()
		}
	}
	
	func stopReducingHeroHealth() {
		if heroIsAttacked {
			heroIsAttacked = false
			stopHealthReductionTimer()
		}
	}
	
	func heroUseMedkit() {
		hero.heroHealthIncreased(health: 20)
		healthBar.update(progress: hero.getHeroHealth() / 100.0)
		updateMedkitButtonState()
	}
	
	func startStaminaReductionTimer() {
		heroStaminaReductionTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(reduceHeroStamina), userInfo: nil, repeats: true)
	}
	
	func stopStaminaReductionTimer() {
		heroStaminaReductionTimer?.invalidate()
		heroStaminaReductionTimer = nil
	}
	
	@objc func reduceHeroStamina() {
		hero.heroStaminaReduced(stamina: 2.0)
		staminaBar.update(progress: hero.getHeroStamina() / 100.0)
	}
	
	private func startStaminaRecoveryTimer() {
		heroStaminaRecoveryTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(recoverHeroStamina), userInfo: nil, repeats: true)
	}
	
	private func stopStaminaRecoveryTimer() {
		heroStaminaRecoveryTimer?.invalidate()
		heroStaminaRecoveryTimer = nil
	}
	
	@objc private func recoverHeroStamina() {
		hero.heroStaminaIncreased(stamina: 1.5)
		staminaBar.update(progress: hero.getHeroStamina() / 100.0)
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		if contact.bodyA.categoryBitMask == ChestCategory || contact.bodyB.categoryBitMask == ChestCategory {
			handleChestCollision(contact: contact)
			
			return
		}
		
		if contact.bodyA.categoryBitMask == LockerCategory || contact.bodyB.categoryBitMask == LockerCategory {
			handleLockerCollision(contact: contact)
			
			return
		}
		
		if contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory {
			handleHeroCollision(contact: contact)
			
			return
		}
	}
	
	func didEnd(_ contact: SKPhysicsContact) {
		if contact.bodyA.categoryBitMask == ChestCategory || contact.bodyB.categoryBitMask == ChestCategory {
			if (contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory) {
				interactButton.isHidden = true
			}
		}
		
		if contact.bodyA.categoryBitMask == LockerCategory || contact.bodyB.categoryBitMask == LockerCategory {
			if (contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory) {
				hidingButton.isHidden = true
			}
		}
		
		if contact.bodyA.categoryBitMask == HeroCategory || contact.bodyB.categoryBitMask == HeroCategory {
			if (contact.bodyA.categoryBitMask == UndeadCategory || contact.bodyB.categoryBitMask == UndeadCategory) {
				undead.physicsBody?.pinned = false
			}
		}
	}
	
	func handleChestCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == ChestCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case HeroCategory:
				interactButton.isHidden = false
			default:
				break
		}
	}
	
	func handleLockerCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == LockerCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case HeroCategory:
				hidingButton.isHidden = false
			default:
				break
		}
	}
	
	func handleHeroCollision(contact: SKPhysicsContact) {
		var otherBody: SKPhysicsBody
		
		if(contact.bodyA.categoryBitMask == HeroCategory) {
			otherBody = contact.bodyB
		} else {
			otherBody = contact.bodyA
		}
		
		switch otherBody.categoryBitMask {
			case UndeadCategory:
				undead.physicsBody?.pinned = true
			case NextFloorCategory:
				let transition = SKTransition.fade(withDuration: 1.0)
				let evacuationScene = EvacuationScene(size: size)
				evacuationScene.scaleMode = scaleMode
				view?.presentScene(evacuationScene, transition: transition)
			default:
				break
		}
	}
	
	func countdownAnnouncement() {
		if countdownManager?.getTimer().remainingTime == 120 {
			subtitleManager.updateSubtitle("All survivors", duration: 2)
			subtitleManager.updateSubtitle("Two minutes before liftoff", duration: 1.75)
			subtitleManager.updateSubtitle("We repeat", duration: 0.75)
			subtitleManager.updateSubtitle("Two minutes before liftoff", duration: 1.75)
			SFXManager.shared.playSFX(name: "Helicopter2Minutes", type: "wav")
		}
		
//		if countdownManager?.getTimer().remainingTime == 3 {
//			SFXManager.shared.playSFX(name: "HelicopterTakeOff", type: "wav")
//			subtitleManager.updateSubtitle("The helicopter is taking off now", duration: 3.25)
//			subtitleManager.updateSubtitle("For survivors who are not evacuated", duration: 2)
//			subtitleManager.updateSubtitle("Await government's radio signals", duration: 1.3)
//			subtitleManager.updateSubtitle("For the next evacuation spot", duration: 1.5)
//			subtitleManager.updateSubtitle("Take care of yourselves", duration: 1.5)
//		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		heroCamera.position = hero.position
		
		let isRunning = runningButton.isRunningButtonPressed && hero.getHeroStamina() > 0
		let heroIsIdleOrHidden = hero.isHidden || hero.isHeroIdle()
		
		let joystickPosition = joystick.stick.position
		
		joystick.isHidden = hero.isHidden
		
		runningButton.isUserInteractionEnabled = !heroIsIdleOrHidden
		
		hero.heroIsMoving(isRunning: isRunning, joystickPosition: joystickPosition)
		undead.undeadIsAttacking(deltaTime: dt, hero: hero, heroIsHidden: hero.isHidden)
		
		healthBar.update(progress: hero.getHeroHealth() / 100.0)
		staminaBar.update(progress: hero.getHeroStamina() / 100.0)
		
		updateMedkitButtonState()
		
		let maskSize = CGSize(width: hospitalGround.size.width, height: hospitalGround.size.height)
		maskNode.position = CGPoint(x: hero.position.x - maskSize.width / 2, y: hero.position.y - maskSize.height / 2)
		
		if hero.isHidden {
			cropNode.maskNode = nil
		} else {
			cropNode.maskNode = maskNode
		}
		
		countdownManager?.updateTimer(dt: dt)
		
		countdownAnnouncement()
	}
}
