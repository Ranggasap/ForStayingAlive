import SpriteKit
import GameplayKit

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
	
	private var backgroundOne: SKSpriteNode!
	private var backgroundTwo: SKSpriteNode!
	
	private var testBackground: SKSpriteNode!
	private var testBoundary: SKSpriteNode!
	
	private var lastUpdateTime: TimeInterval = 0
	
	private var minX: CGFloat = 0
	private var maxX: CGFloat = 0
	private var minY: CGFloat = 0
	private var maxY: CGFloat = 0
	
	var maskNode: SKShapeNode!
	var darkOverlay: SKSpriteNode!
	var cropNode: SKCropNode!
	
	override func didMove(to view: SKView) {
		physicsWorld.contactDelegate = self
		
		setupHeroCamera()
		
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
		
//		addBackground()
		addJoystick()
		addRunningButton()
		addInteractButton()
		addHidingButton()
		addMedkitButton()
		addStatusBar()
		
		spawnHero()
		spawnUndead()
		spawnChest()
		spawnLocker()
		
		addLightingEffect()
		
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
	}
	
	func addLightingEffect() {
		// Create dark overlay
		darkOverlay = SKSpriteNode(color: .black, size: CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2))
		darkOverlay.position = CGPoint(x: frame.midX, y: frame.midY)
		darkOverlay.alpha = 0.9 // Adjust as needed
		darkOverlay.zPosition = 5
		darkOverlay.isUserInteractionEnabled = false
		
		// Create circular mask
		let maskRadius: CGFloat = 100.0 // Adjust the radius as needed
		let maskSize = CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2)
		
		let maskPath = CGMutablePath()
		maskPath.addRect(CGRect(origin: .zero, size: maskSize))
		maskPath.addArc(center: CGPoint(x: maskSize.width / 2, y: maskSize.height / 2), radius: maskRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
		
		maskNode = SKShapeNode(path: maskPath)
		maskNode.fillColor = .black
		maskNode.strokeColor = .clear
		maskNode.lineWidth = 0
		maskNode.isUserInteractionEnabled = false
		
		// Create crop node
		cropNode = SKCropNode()
		cropNode.maskNode = maskNode
		
		// Add dark overlay to crop node
		cropNode.addChild(darkOverlay)
		cropNode.zPosition = 4 // Ensure it's above other nodes
		cropNode.isUserInteractionEnabled = false
		
		// Add crop node to scene
		addChild(cropNode)
	}
	
	func addBackground() {
		backgroundOne = SKSpriteNode(imageNamed: "background")
		backgroundOne.size = self.size
		backgroundOne.position = CGPoint(x: frame.midX, y: frame.midY)
		backgroundOne.zPosition = -1
		addChild(backgroundOne)
		
		backgroundTwo = SKSpriteNode(imageNamed: "background")
		backgroundTwo.size = self.size
		backgroundTwo.position = CGPoint(x: backgroundOne.position.x + backgroundTwo.frame.width / 2, y: frame.midY)
		backgroundTwo.zPosition = -1
		addChild(backgroundTwo)
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
		interactButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 170)
		interactButton.zPosition = 10
		interactButton.setMedkitButton(medkitButton)
		heroCamera.addChild(interactButton)
	}
	
	func addHidingButton() {
		hidingButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 170)
		hidingButton.zPosition = 10
		heroCamera.addChild(hidingButton)
	}
	
	func addMedkitButton() {
		medkitButton.position = CGPoint(x: size.width / 2 - 135, y: size.height / 2 - 35)
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
		locker.position = CGPoint(x: frame.minX + 150, y: frame.midY + 50)
		addChild(locker)
	}
	
	func clampPosition(of node: SKNode) {
		node.position.x = min(maxX, max(minX, node.position.x))
		node.position.y = min(maxY, max(minY, node.position.y))
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
		
		runningButton.isUserInteractionEnabled = !heroIsIdleOrHidden /*&& heroIsMoving*/
		
		hero.heroIsMoving(isRunning: isRunning, joystickPosition: joystickPosition)
		undead.undeadIsAttacking(deltaTime: dt, hero: hero, heroIsHidden: hero.isHidden)
		
		healthBar.update(progress: hero.getHeroHealth() / 100.0)
		staminaBar.update(progress: hero.getHeroStamina() / 100.0)
		
		updateMedkitButtonState()
		
		// Update maskNode position to follow the hero
		let maskSize = CGSize(width: testBackground.size.width * 2, height: testBackground.size.height * 2)
		maskNode.position = CGPoint(x: hero.position.x - maskSize.width / 2, y: hero.position.y - maskSize.height / 2)
	}
}
