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
    private var mediumImpactFeedbackGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .medium)
    
    private let hero = HeroSprite.newInstance()
    
    private let undeadOne = UndeadSprite.newInstance()
    private let undeadTwo = UndeadSprite.newInstance()
    private let undeadThree = UndeadSprite.newInstance()
    
    private let chestOne = ChestSprite.newInstance()
    private let chestTwo = ChestSprite.newInstance()
    private let chestThree = ChestSprite.newInstance()
    
    private let lockerOne = LockerSprite.newInstance()
    private let lockerTwo = LockerSprite.newInstance()
    private let lockerThree = LockerSprite.newInstance()
    
    private let runningButton = RunningButton.newInstance()
    private let medkitButton = MedkitButton.newInstance()
    private let interactButton = InteractButton.newInstance()
    private let hidingButton = HidingButton.newInstance()
    
    private let healthBar = ProgressBarNode(color: .systemRed, size: CGSize(width: 100, height: 10))
    private let staminaBar = ProgressBarNode(color: .systemGreen, size: CGSize(width: 100, height: 10))
    
    private var heroHealthReductionTimer: Timer?
    private var undeadsInRange: Set<UndeadSprite> = []
    
    private var heroStaminaReductionTimer: Timer?
    private var heroStaminaRecoveryTimer: Timer?
    
    private let heroCamera = SKCameraNode()
    
    private var joystick: AnalogJoystick!
    
    private var nextSceneNode = NextSceneNode(size: CGSize(width: 50, height: 50))
    
    private var hospitalGround: SKSpriteNode!
    private var hospitalBoundary: SKSpriteNode!
    
    private var furnitureBoundaryOne: SKSpriteNode!
    private var furnitureBoundaryTwo: SKSpriteNode!
    private var furnitureBoundaryThree: SKSpriteNode!
    private var furnitureBoundaryFour: SKSpriteNode!
    private var furnitureBoundaryFive: SKSpriteNode!
    private var furnitureBoundarySix: SKSpriteNode!
    
    private var lastUpdateTime: TimeInterval = 0
    
    private var subtitleManager: SubtitleManager!
    private var twoMinutesAnnouncementMade = false
    private var takeOffAnnouncementMade = false
    
    private var maskNode: SKShapeNode!
    private var darkOverlay: SKSpriteNode!
    private var cropNode: SKCropNode!
    
    private var countdownViewModel = CountdownTimerViewModel()
    private var countdownManager: CountdownManager?
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var countdownLabel: SKLabelNode!
    
    private var backgroundTrack: AVAudioPlayer?
    private var helicopterTrack: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
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
        
        let maskRadius: CGFloat = 90.0
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
        subtitleManager.updateSubtitle("Attention all survivors", duration: 1.6)
        subtitleManager.updateSubtitle("The helicopter takes off in 5 minutes", duration: 2.5)
        subtitleManager.updateSubtitle("Get to the rooftop now", duration: 1.6)
        subtitleManager.updateSubtitle("We repeat", duration: 0.75)
        subtitleManager.updateSubtitle("Get to the rooftop now", duration: 1.6)
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
        hospitalGround.zPosition = -1
        addChild(hospitalGround)
        
        hospitalBoundary = SKSpriteNode(imageNamed: "hospital-boundary")
        hospitalBoundary.size = CGSize(width: hospitalBoundary.size.width, height: hospitalBoundary.size.height)
        hospitalBoundary.position = CGPoint(x: frame.midX, y: frame.midY)
        hospitalBoundary.zPosition = -10
        
        let boundaryTexture = hospitalBoundary.texture
        hospitalBoundary.physicsBody = SKPhysicsBody(texture: boundaryTexture!, size: hospitalBoundary.size)
        hospitalBoundary.physicsBody?.affectedByGravity = false
        hospitalBoundary.physicsBody?.isDynamic = false
        addChild(hospitalBoundary)
        
        furnitureBoundaryOne = SKSpriteNode(imageNamed: "furniture-boundary-1")
        furnitureBoundaryOne.size = CGSize(width: furnitureBoundaryOne.size.width, height: furnitureBoundaryOne.size.height)
        furnitureBoundaryOne.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundaryOne.zPosition = -6
        
        let furnitureOneBoundaryTexture = furnitureBoundaryOne.texture
        furnitureBoundaryOne.physicsBody = SKPhysicsBody(texture: furnitureOneBoundaryTexture!, size: furnitureBoundaryOne.size)
        furnitureBoundaryOne.physicsBody?.affectedByGravity = false
        furnitureBoundaryOne.physicsBody?.isDynamic = false
        addChild(furnitureBoundaryOne)
        
        furnitureBoundaryTwo = SKSpriteNode(imageNamed: "furniture-boundary-2")
        furnitureBoundaryTwo.size = CGSize(width: furnitureBoundaryTwo.size.width, height: furnitureBoundaryTwo.size.height)
        furnitureBoundaryTwo.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundaryTwo.zPosition = -8
        furnitureBoundaryTwo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: furnitureBoundaryTwo.size.width / 2, height: furnitureBoundaryTwo.size.height / 2))
        
        let furnitureTwoBoundaryTexture = furnitureBoundaryTwo.texture
        furnitureBoundaryTwo.physicsBody = SKPhysicsBody(texture: furnitureTwoBoundaryTexture!, size: furnitureBoundaryTwo.size)
        furnitureBoundaryTwo.physicsBody?.affectedByGravity = false
        furnitureBoundaryTwo.physicsBody?.isDynamic = false
        addChild(furnitureBoundaryTwo)
        
        furnitureBoundaryThree = SKSpriteNode(imageNamed: "furniture-boundary-3")
        furnitureBoundaryThree.size = CGSize(width: furnitureBoundaryThree.size.width, height: furnitureBoundaryThree.size.height)
        furnitureBoundaryThree.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundaryThree.zPosition = -7
        furnitureBoundaryThree.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: furnitureBoundaryThree.size.width / 2, height: furnitureBoundaryThree.size.height / 2))
        
        let furnitureThreeBoundaryTexture = furnitureBoundaryThree.texture
        furnitureBoundaryThree.physicsBody = SKPhysicsBody(texture: furnitureThreeBoundaryTexture!, size: furnitureBoundaryThree.size)
        furnitureBoundaryThree.physicsBody?.affectedByGravity = false
        furnitureBoundaryThree.physicsBody?.isDynamic = false
        addChild(furnitureBoundaryThree)
        
        furnitureBoundaryFour = SKSpriteNode(imageNamed: "furniture-boundary-4")
        furnitureBoundaryFour.size = CGSize(width: furnitureBoundaryFour.size.width, height: furnitureBoundaryFour.size.height)
        furnitureBoundaryFour.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundaryFour.zPosition = -6
        furnitureBoundaryFour.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: furnitureBoundaryFour.size.width / 2, height: furnitureBoundaryFour.size.height / 2))
        
        let furnitureFourBoundaryTexture = furnitureBoundaryFour.texture
        furnitureBoundaryFour.physicsBody = SKPhysicsBody(texture: furnitureFourBoundaryTexture!, size: furnitureBoundaryFour.size)
        furnitureBoundaryFour.physicsBody?.affectedByGravity = false
        furnitureBoundaryFour.physicsBody?.isDynamic = false
        addChild(furnitureBoundaryFour)
        
        furnitureBoundaryFive = SKSpriteNode(imageNamed: "furniture-boundary-5")
        furnitureBoundaryFive.size = CGSize(width: furnitureBoundaryFive.size.width, height: furnitureBoundaryFive.size.height)
        furnitureBoundaryFive.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundaryFive.zPosition = -5
        furnitureBoundaryFive.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: furnitureBoundaryFive.size.width / 2, height: furnitureBoundaryFive.size.height / 2))
        
        let furnitureFiveBoundaryTexture = furnitureBoundaryFive.texture
        furnitureBoundaryFive.physicsBody = SKPhysicsBody(texture: furnitureFiveBoundaryTexture!, size: furnitureBoundaryFive.size)
        furnitureBoundaryFive.physicsBody?.affectedByGravity = false
        furnitureBoundaryFive.physicsBody?.isDynamic = false
        addChild(furnitureBoundaryFive)
        
        furnitureBoundarySix = SKSpriteNode(imageNamed: "furniture-boundary-6")
        furnitureBoundarySix.size = CGSize(width: furnitureBoundarySix.size.width, height: furnitureBoundarySix.size.height)
        furnitureBoundarySix.position = CGPoint(x: frame.midX, y: frame.midY)
        furnitureBoundarySix.zPosition = -4
        furnitureBoundarySix.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: furnitureBoundarySix.size.width / 2, height: furnitureBoundarySix.size.height / 2))
        
        let furnitureSixBoundaryTexture = furnitureBoundarySix.texture
        furnitureBoundarySix.physicsBody = SKPhysicsBody(texture: furnitureSixBoundaryTexture!, size: furnitureBoundarySix.size)
        furnitureBoundarySix.physicsBody?.affectedByGravity = false
        furnitureBoundarySix.physicsBody?.isDynamic = false
        addChild(furnitureBoundarySix)
    }
    
    func addJoystick() {
        let joystickDiameter: CGFloat = min(size.width, size.height) * 0.25
        
        let substrate = AnalogJoystickSubstrate(diameter: joystickDiameter, borderColor: .gray, fillColor: .white)
        substrate.borderWidth = 10.0
        
        let stick = AnalogJoystickStick(diameter: joystickDiameter * 0.6, borderColor: .gray, fillColor: .gray)
        
        joystick = AnalogJoystick(substrate: substrate, stick: stick)
        joystick.position = CGPoint(x: -size.width / 2 + 125, y: -size.height / 2 + 90)
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
        hero.position = CGPoint(x: frame.maxX, y: frame.minY - 250)
        hero.name = "Hero"
        addChild(hero)
    }
    
    func spawnUndead() {
        undeadOne.position = CGPoint(x: frame.midX - 300, y: frame.midY + 170)
        undeadOne.name = "undead-one"
        undeadOne.setUndeadSpawnPosition()
        addChild(undeadOne)
        
        undeadTwo.position = CGPoint(x: frame.maxX - 100, y: frame.midY + 80)
        undeadTwo.name = "undead-two"
        undeadTwo.setUndeadSpawnPosition()
        addChild(undeadTwo)
        
        undeadThree.position = CGPoint(x: frame.maxX - 300, y: frame.minY - 130)
        undeadThree.name = "undead-three"
        undeadThree.setUndeadSpawnPosition()
        addChild(undeadThree)
        
        undeadOne.onHeroEnterAttackRange = { [weak self] in
            self?.heroEnteredUndeadRange(undead: self?.undeadOne)
        }
        
        undeadOne.onHeroExitAttackRange = { [weak self] in
            self?.heroExitedUndeadRange(undead: self?.undeadOne)
        }
        
        undeadTwo.onHeroEnterAttackRange = { [weak self] in
            self?.heroEnteredUndeadRange(undead: self?.undeadTwo)
        }
        
        undeadTwo.onHeroExitAttackRange = { [weak self] in
            self?.heroExitedUndeadRange(undead: self?.undeadTwo)
        }
        
        undeadThree.onHeroEnterAttackRange = { [weak self] in
            self?.heroEnteredUndeadRange(undead: self?.undeadThree)
        }
        
        undeadThree.onHeroExitAttackRange = { [weak self] in
            self?.heroExitedUndeadRange(undead: self?.undeadThree)
        }
    }
    
    func spawnChest() {
        chestOne.position = CGPoint(x: frame.minX + 140, y: frame.midY + 40)
        addChild(chestOne)
        
        chestTwo.position = CGPoint(x: frame.minX - 90, y: frame.minY - 320)
        addChild(chestTwo)
        
        chestThree.position = CGPoint(x: frame.midX - 80, y: frame.midY + 270)
        addChild(chestThree)
    }
    
    func spawnLocker() {
        lockerOne.position = CGPoint(x: frame.maxX + 80, y: frame.maxY + 190)
        addChild(lockerOne)
        
        lockerTwo.position = CGPoint(x: frame.midX - 50, y: frame.minY - 120)
        addChild(lockerTwo)
        
        lockerThree.position = CGPoint(x: frame.maxX - 220, y: frame.maxY + 70)
        addChild(lockerThree)
    }
    
    func spawnNextFloor() {
        nextSceneNode.position = CGPoint(x: frame.minX - 40, y: frame.midY + 520)
        addChild(nextSceneNode)
    }
    
    func heroEnteredUndeadRange(undead: UndeadSprite?) {
        guard let undead = undead else { return }
        undeadsInRange.insert(undead)
        startReducingHeroHealth()
    }
    
    func heroExitedUndeadRange(undead: UndeadSprite?) {
        guard let undead = undead else { return }
        undeadsInRange.remove(undead)
        stopReducingHeroHealth()
    }
    
    func startReducingHeroHealth() {
        let biteSound = SKAction.playSoundFileNamed("undead-bite", waitForCompletion: false)
        let flashRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.1)
        let clearColor = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        let flashSequence = SKAction.sequence([flashRed, clearColor])
        
        if heroHealthReductionTimer == nil && !undeadsInRange.isEmpty {
            heroHealthReductionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.hero.heroHealthReduced(health: 10)
                self.run(biteSound)
                self.hero.run(flashSequence)
                
                self.mediumImpactFeedbackGenerator?.prepare()
                self.mediumImpactFeedbackGenerator?.impactOccurred()
                
                let heroHealth = hero.getHeroHealth()
                if heroHealth == 0 {
                    mediumImpactFeedbackGenerator = nil
                }
            }
        }
    }
    
    func stopReducingHeroHealth() {
        if undeadsInRange.isEmpty {
            heroHealthReductionTimer?.invalidate()
            heroHealthReductionTimer = nil
        }
    }
    
    func heroUseMedkit() {
        hero.heroHealthIncreased(health: 20)
        healthBar.update(progress: hero.getHeroHealth() / 100.0)
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
    }
    
    private func startStaminaRecoveryTimer() {
        heroStaminaRecoveryTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(recoverHeroStamina), userInfo: nil, repeats: true)
    }
    
    private func stopStaminaRecoveryTimer() {
        heroStaminaRecoveryTimer?.invalidate()
        heroStaminaRecoveryTimer = nil
    }
    
    @objc private func recoverHeroStamina() {
        hero.heroStaminaIncreased(stamina: 2.0)
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
                if contact.bodyA.node?.name == "undead-one" || contact.bodyB.node?.name == "undead-one" {
                    undeadOne.physicsBody?.pinned = false
                }
                
                if contact.bodyA.node?.name == "undead-two" || contact.bodyB.node?.name == "undead-two" {
                    undeadTwo.physicsBody?.pinned = false
                }
                
                if contact.bodyA.node?.name == "undead-three" || contact.bodyB.node?.name == "undead-three" {
                    undeadThree.physicsBody?.pinned = false
                }
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
            if otherBody.node?.name == "undead-one" {
                undeadOne.physicsBody?.pinned = true
            }
            
            if otherBody.node?.name == "undead-two" {
                undeadTwo.physicsBody?.pinned = true
            }
            
            if otherBody.node?.name == "undead-three" {
                undeadThree.physicsBody?.pinned = true
            }
        case NextSceneCategory:
            let transition = SKTransition.fade(withDuration: 1.0)
            let evacuationScene = EvacuationScene(size: size)
            evacuationScene.scaleMode = scaleMode
            view?.presentScene(evacuationScene, transition: transition)
        default:
            break
        }
    }
    
    func countdownAnnouncement() {
        if let remainingTime = countdownManager?.getTimer().remainingTime {
            if remainingTime <= 120 && !twoMinutesAnnouncementMade {
                subtitleManager.updateSubtitle("All survivors", duration: 2)
                subtitleManager.updateSubtitle("Two minutes before liftoff", duration: 1.75)
                subtitleManager.updateSubtitle("We repeat", duration: 0.75)
                subtitleManager.updateSubtitle("Two minutes before liftoff", duration: 1.75)
                SFXManager.shared.playSFX(name: "Helicopter2Minutes", type: "wav")
                twoMinutesAnnouncementMade = true
            }
            
            if remainingTime <= 1 && !takeOffAnnouncementMade {
                let transition = SKTransition.fade(withDuration: 1.0)
                let gameOverScene = LeftBehindScene(size: size)
                gameOverScene.scaleMode = scaleMode
                view?.presentScene(gameOverScene, transition: transition)
                takeOffAnnouncementMade = true
            }
        }
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
        undeadOne.undeadIsAttacking(deltaTime: dt, hero: hero, heroIsHidden: hero.isHidden)
        undeadTwo.undeadIsAttacking(deltaTime: dt, hero: hero, heroIsHidden: hero.isHidden)
        undeadThree.undeadIsAttacking(deltaTime: dt, hero: hero, heroIsHidden: hero.isHidden)
        
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
