//
//  ProgressBarNode.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 11/06/24.
//

import SpriteKit
import GameplayKit
import Combine

class ExplorationMap: SKScene, SKPhysicsContactDelegate {
	private let hero = HeroSprite.newInstance()
	private let undead = UndeadSprite.newInstance()
	private let chest = ChestSprite.newInstance()
	private let locker = LockerSprite.newInstance()
	
	private let runningButton = RunningButton.newInstance()
	private let medkitButton = MedkitButton.newInstance()
	private let interactButton = InteractButton.newInstance()
	private let hidingButton = HidingButton.newInstance()
	
	private let healthBar = ProgressBarNode(color: .red, size: CGSize(width: 100, height: 10))
	private let staminaBar = ProgressBarNode(color: .blue, size: CGSize(width: 100, height: 10))
	
	private var heroIsAttacked = false
	private var heroHealthReductionTimer: Timer?
	
	private var heroStaminaReductionTimer: Timer?
	private var heroStaminaRecoveryTimer: Timer?
	
	private let heroCamera = SKCameraNode()
	
	private var joystick: AnalogJoystick!

    private let hideButton = HideButtonSprite()
    
    private var nextSceneNode = NextSceneNode(size: CGSize(width: 50, height: 50))
	
	private var backgroundOne: SKSpriteNode!
	private var backgroundTwo: SKSpriteNode!
	
	private var testBackground: SKSpriteNode!
	private var testBoundary: SKSpriteNode!
	
	private var lastUpdateTime: TimeInterval = 0
	
	private var minX: CGFloat = 0
	private var maxX: CGFloat = 0
	private var minY: CGFloat = 0
	private var maxY: CGFloat = 0
	
	private var maskNode: SKShapeNode!
	private var darkOverlay: SKSpriteNode!
	private var cropNode: SKCropNode!

    
    private var thrillerBackSoundEffect = Sound(fileName: "the-hired-thriller-drama-mystery-background-111015", fileType: "mp3")
    private var helicopterSoundEffect = Sound(fileName: "helicopter-129052", fileType: "mp3")
    
    private var countdownViewModel = CountdownTimerViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private var countdownLabel: SKLabelNode!
    
	override func didMove(to view: SKView) {
        countdownLabel = SKLabelNode(text: "--:--")
        countdownLabel.fontSize = 45
        countdownLabel.fontName = "Helvetica-Bold"
        countdownLabel.position = CGPoint(x: heroCamera.position.x, y: heroCamera.position.y + 125)
        heroCamera.addChild(countdownLabel)
        
        countdownViewModel.$displayTime.receive(on: RunLoop.main).sink{ [weak self] newTime in
            self?.countdownLabel.text = newTime
        }.store(in: &cancellables)
        
        countdownViewModel.startTimer()
        
        SoundManager.shared.playSound(thrillerBackSoundEffect, withIdentifier: "backSoundEffect")
        SoundManager.shared.setVolume(for: "backSoundEffect", volume: 0.5)
        SoundManager.shared.playSound(helicopterSoundEffect, withIdentifier: "helicopterSoundEffect")
        SoundManager.shared.setVolume(for: "helicopterSoundEffect", volume: 0.5)
        
		self.physicsWorld.contactDelegate = self

		hideButton.setup()
		hideButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 200)
		hideButton.hideButtonAction = {
			if(self.hero.isHidden == true){
				self.hero.isHidden = false
				self.hideButton.hideButtonChange()
			} else {
				self.hero.isHidden = true
				self.hideButton.hideButtonChange()
			}
		}
		hideButton.isHidden = true
		heroCamera.addChild(hideButton)
        

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
		
		spawnHero()
		spawnUndead()
		spawnChest()
		spawnLocker()
		
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
		
//		minX = frame.minX + 70
//		maxX = backgroundOne.position.x + backgroundTwo.position.x - 70
//		minY = frame.minY + 50
//		maxY = frame.midY + 70
        
      
        nextSceneNode.position = CGPoint(x: frame.midX - 50, y: frame.midY)
        addChild(nextSceneNode)
	}
	
	func addBackgroundMusic() {
		let backgroundTrack = SoundManager.sharedInstance.startPlaying(soundName: "the-hired", fileExtension: "m4a")
		backgroundTrack?.volume = 0.8
		
		let helicopterTrack = SoundManager.sharedInstance.startPlaying(soundName: "helicopter", fileExtension: "m4a")
		helicopterTrack?.volume = 0.6
	}
	
	func addVisibilityEffect() {
		darkOverlay = SKSpriteNode(color: .black, size: CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2))
		darkOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
		darkOverlay.alpha = 0.9
		darkOverlay.zPosition = 5
		darkOverlay.isUserInteractionEnabled = false
		
		let maskRadius: CGFloat = 90.0
		let maskSize = CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2)
		
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

    
    func heroEndCollisionHandler(contact: SKPhysicsContact){
        var otherBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == HeroCategory{
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask{
        case LockerCategory:
            hideButton.isHidden = true
            print("Hero run away locker")
        default:
            print("Hero doesn't get hit with anything")
        }
    }
    
    func heroCollisionHandler(contact: SKPhysicsContact){
        var otherBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == HeroCategory{
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask{
        case NextSceneCategory:
            print("Next Scene")
            let transition = SKTransition.fade(withDuration: 1.0)
            let evacuationScene = EvacuationScene(size: size)
            evacuationScene.scaleMode = scaleMode
            
            view?.presentScene(evacuationScene, transition: transition)
            
        case UndeadCategory:
            hero.healthReduce(health: 25)
        case LockerCategory:
            hideButton.isHidden = false
            print("Hero hit Locker")
        default:
            print("Something Hit Hero")
        }
    }
    
    func addStatusBar(){
        healthBar.position = CGPoint(x: -size.width / 2 + 150, y: -size.height / 2 + 350)
        heroCamera.addChild(healthBar)
        
        staminaBar.position = CGPoint(x: -size.width / 2 + 150, y: -size.height / 2 + 320)
        heroCamera.addChild(staminaBar)
    }
	
	func addBackground() {
		testBackground = SKSpriteNode(imageNamed: "test_map")
		testBackground.size = CGSize(width: testBackground.size.width, height: testBackground.size.height)
		testBackground.position = CGPoint(x: frame.midX, y: frame.midY)
		testBackground.zPosition = 0
		addChild(testBackground)
		
		testBoundary = SKSpriteNode(imageNamed: "boundary")
		testBoundary.size = CGSize(width: testBoundary.size.width, height: testBoundary.size.height)
		testBoundary.position = CGPoint(x: frame.midX, y: frame.midY)
		testBoundary.zPosition = -1
		
		let boundaryTexture = testBoundary.texture
		testBoundary.physicsBody = SKPhysicsBody(texture: boundaryTexture!, size: testBoundary.size)
		testBoundary.physicsBody?.affectedByGravity = false
		testBoundary.physicsBody?.isDynamic = false
		addChild(testBoundary)
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
		
		joystick.trackingHandler = { [unowned self] data in
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
		healthBar.position = CGPoint(x: -size.width / 2 + 150, y: size.height / 2 - 30)
		healthBar.zPosition = 10
		heroCamera.addChild(healthBar)
		
		staminaBar.position = CGPoint(x: -size.width / 2 + 150, y: size.height / 2 - 45)
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
		chest.position = CGPoint(x: frame.midX, y: frame.midY - 100)
		addChild(chest)
	}
	
	func spawnLocker() {
		locker.position = CGPoint(x: frame.minX + 150, y: frame.midY + 30)
		addChild(locker)
	}
	
//	func clampPosition(of node: SKNode) {
//		node.position.x = min(maxX, max(minX, node.position.x))
//		node.position.y = min(maxY, max(minY, node.position.y))
//	}
	
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
			default:
				break
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		let dt = currentTime - self.lastUpdateTime
		self.lastUpdateTime = currentTime
		
		healthBar.update(datetime: dt, progress: hero.getStatus().0 / 100)
		staminaBar.update(datetime: dt, progress: hero.getStatus().1 / 100)
        
//		clampPosition(of: hero)
//		clampPosition(of: undead)

//		let cameraX = max(hero.position.x, size.width / 2)
//		let maxCameraX = backgroundOne.position.x + backgroundTwo.frame.width / 2
//		heroCamera.position.x = min(maxCameraX, cameraX)
		
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
		
		let maskSize = CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2)
		maskNode.position = CGPoint(x: hero.position.x - maskSize.width / 2, y: hero.position.y - maskSize.height / 2)
	}
}
