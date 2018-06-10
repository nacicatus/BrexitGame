//
//  Cameron.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class Cameron: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"enemies.atlas")
    var fadeAnimation = SKAction()
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 60, height: 88)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.damagedPolitician.rawValue
        self.texture = textureAtlas.textureNamed("cameron.png")
        self.run(fadeAnimation)
        // Cameron is a ghost!
        self.alpha = 0.8;
    }
    
    func createAnimations() {
        // Create a fade out action group:
        // The ghost becomes slightly smaller and more transparent.
        let fadeOutGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.3, duration: 2),
            SKAction.scale(to: 0.8, duration: 2)
            ]);
        // Create a fade in action group:
        // The ghost returns to full size and initial transparency.
        let fadeInGroup = SKAction.group([
            SKAction.fadeAlpha(to: 0.8, duration: 2),
            SKAction.scale(to: 1, duration: 2)
            ]);
        // Package the groups into a sequence, then a repeatActionForever action:
        let fadeSequence = SKAction.sequence([fadeOutGroup, fadeInGroup])
        fadeAnimation = SKAction.repeatForever(fadeSequence)
    }
    
    func onTap() {}
}
