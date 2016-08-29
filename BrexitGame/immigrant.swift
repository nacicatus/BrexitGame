//
//  immigrant.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class Immigrant: SKSpriteNode, GameSprite {
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "enemies.atlas")
    var flyAnimation = SKAction()
    
    func spawn(parentNode: SKNode, position: CGPoint, size: CGSize = CGSize(width: 88, height: 48)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(flyAnimation)
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy.rawValue
        self.physicsBody?.collisionBitMask = ~PhysicsCategory.damagedPolitician.rawValue
    }
    func createAnimations() {
        let flyFrames:[SKTexture] = [
            textureAtlas.textureNamed("immigrant-1.png"),
            textureAtlas.textureNamed("immigrant-2.png"),
            textureAtlas.textureNamed("immigrant-3.png"),
            textureAtlas.textureNamed("immigrant-4.png"),
            textureAtlas.textureNamed("immigrant-3.png"),
            textureAtlas.textureNamed("immigrant-2.png")
        ]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.06)
        flyAnimation = SKAction.repeatActionForever(flyAction)
    }
    
    func onTap() {
    }

    
}
