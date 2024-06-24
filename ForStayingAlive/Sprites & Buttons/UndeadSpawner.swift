//
//  UndeadSpawner.swift
//  ForStayingAlive
//
//  Created by Filbert Chai on 24/06/24.
//

import SpriteKit

class UndeadSpawner {
    static func spawnUndead(in scene: SKScene, hero: HeroSprite) -> [UndeadSprite] {
        let undeadOne = UndeadSprite.newInstance()
        let undeadTwo = UndeadSprite.newInstance()
        let undeadThree = UndeadSprite.newInstance()
        
        undeadOne.position = CGPoint(x: scene.frame.midX - 400, y: scene.frame.midY + 120)
        undeadOne.name = "undead-one"
        undeadOne.setUndeadSpawnPosition()
        scene.addChild(undeadOne)
        
        undeadTwo.position = CGPoint(x: scene.frame.maxX + 10, y: scene.frame.midY + 70)
        undeadTwo.name = "undead-two"
        undeadTwo.setUndeadSpawnPosition()
        scene.addChild(undeadTwo)
        
        undeadThree.position = CGPoint(x: scene.frame.maxX - 150, y: scene.frame.midY - 200)
        undeadThree.name = "undead-three"
        undeadThree.setUndeadSpawnPosition()
        scene.addChild(undeadThree)
        
        setupUndeadCallbacks(for: undeadOne, in: scene, hero: hero)
        setupUndeadCallbacks(for: undeadTwo, in: scene, hero: hero)
        setupUndeadCallbacks(for: undeadThree, in: scene, hero: hero)
        
        return [undeadOne, undeadTwo, undeadThree]
    }
    
    private static func setupUndeadCallbacks(for undead: UndeadSprite, in scene: SKScene, hero: HeroSprite) {
        undead.onHeroEnterAttackRange = { [weak scene] in
            guard let scene = scene as? ExplorationMap else { return }
            scene.heroEnteredUndeadRange(undead: undead)
        }
        
        undead.onHeroExitAttackRange = { [weak scene] in
            guard let scene = scene as? ExplorationMap else { return }
            scene.heroExitedUndeadRange(undead: undead)
        }
    }
}
