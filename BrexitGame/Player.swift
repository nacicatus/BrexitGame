//
//  Player.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class Player : SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"boris.atlas")
    var flyAnimation = SKAction()
    var soarAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
   
    var flapping = false
   
    let maxFlappingForce:CGFloat = 57000
  
    let maxHeight:CGFloat = 1000
    var health:Int = 3
    var damaged = false
    var invulnerable = false
    var forwardVelocity:CGFloat = 200
    let powerupSound =
    SKAction.playSoundFileNamed("Sound/Powerup.aif",
        waitForCompletion: false)
    let hurtSound =
    SKAction.playSoundFileNamed("Sound/Hurt.aif",
        waitForCompletion: false)
    
    func spawn(parentNode:SKNode, position: CGPoint, size: CGSize = CGSize(width: 96, height: 96)) {
        parentNode.addChild(self)
        createAnimations()
        self.size = size
        self.position = position
        self.runAction(soarAnimation, withKey: "soarAnimation")
        
        let physicsTexture = textureAtlas.textureNamed("boris-flying-3.png")
        self.physicsBody = SKPhysicsBody(
            texture: physicsTexture,
            size: size)
       
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.linearDamping = 0.9
        self.physicsBody?.mass = 30
        self.physicsBody?.categoryBitMask = PhysicsCategory.politician.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.enemy.rawValue |
            PhysicsCategory.ground.rawValue |
            PhysicsCategory.powerup.rawValue |
            PhysicsCategory.coin.rawValue
        
        // Instantiate an SKEmitterNode with the BorisPath design:
        let dotEmitter = SKEmitterNode(fileNamed: "BorisPath.sks")
        // Place the particle zPosition behind the penguin:
        dotEmitter!.particleZPosition = -1
        // By adding the emitter node to the player, the emitter will move forward
        // with the player and spawn new dots wherever the player moves:
        self.addChild(dotEmitter!)
        // However, we need the particles themselves to be part of the world,
        // so they trail behind the player. Otherwise, they move forward with Boris.
        // (Note that self.parent refers to the world node)
        dotEmitter!.targetNode = self.parent
        
        // Grant a momentary reprieve from gravity:
        self.physicsBody?.affectedByGravity = false
        // Add some slight upward velocity:
        self.physicsBody?.velocity.dy = 50
        // Create an SKAction to start gravity after a small delay:
        let startGravitySequence = SKAction.sequence([
            SKAction.waitForDuration(0.6),
            SKAction.runBlock {
                self.physicsBody?.affectedByGravity = true
            }])
        self.runAction(startGravitySequence)
    }
    
    func createAnimations() {
        let rotateUpAction = SKAction.rotateToAngle(0, duration: 0.475)
        rotateUpAction.timingMode = .EaseOut
        let rotateDownAction = SKAction.rotateToAngle(-1, duration: 0.8)
        rotateDownAction.timingMode = .EaseIn
        
        // 
        let flyFrames:[SKTexture] = [
            textureAtlas.textureNamed("boris-flying-1.png"),
            textureAtlas.textureNamed("boris-flying-2.png"),
            textureAtlas.textureNamed("boris-flying-3.png"),
            textureAtlas.textureNamed("boris-flying-4.png"),
            textureAtlas.textureNamed("boris-flying-3.png"),
            textureAtlas.textureNamed("boris-flying-2.png")
        ]
        let flyAction = SKAction.animateWithTextures(flyFrames, timePerFrame: 0.03)
        flyAnimation = SKAction.group([
            SKAction.repeatActionForever(flyAction),
            rotateUpAction
            ])
        
        // Create the soaring animation, just one frame for now:
        let soarFrames:[SKTexture] = [textureAtlas.textureNamed("boris-flying-1.png")]
        let soarAction = SKAction.animateWithTextures(soarFrames, timePerFrame: 1)
        soarAnimation = SKAction.group([
            SKAction.repeatActionForever(soarAction),
            rotateDownAction
            ])
        
        // --- Create the taking damage animation ---
        let damageStart = SKAction.runBlock {
            
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPolitician.rawValue
           
            self.physicsBody?.collisionBitMask = ~PhysicsCategory.enemy.rawValue
        }
        // Create an opacity fade out and in, slow at first and fast at the end:
        let slowFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.35),
            SKAction.fadeAlphaTo(0.7, duration: 0.35)
            ])
        let fastFade = SKAction.sequence([
            SKAction.fadeAlphaTo(0.3, duration: 0.2),
            SKAction.fadeAlphaTo(0.7, duration: 0.2)
            ])
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeatAction(slowFade, count: 2),
            SKAction.repeatAction(fastFade, count: 5),
            SKAction.fadeAlphaTo(1, duration: 0.15)
            ])
        // Return the penguin to normal:
        let damageEnd = SKAction.runBlock {
            self.physicsBody?.categoryBitMask = PhysicsCategory.politician.rawValue
            // Collide with everything again:
            self.physicsBody?.collisionBitMask = 0xFFFFFFFF
            self.damaged = false
        }
        // Wire it all together and store it in the damageAnimation property:
        self.damageAnimation = SKAction.sequence([
            damageStart,
            fadeOutAndIn,
            damageEnd
            ])
        
        
        /* --- Create the death animation --- */
        let startDie = SKAction.runBlock {
            // Switch to the death texture:
            self.texture = self.textureAtlas.textureNamed("boris-dead.png")
            // Suspend the penguin in space:
            self.physicsBody?.affectedByGravity = false
            // Stop any momentum:
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // Make the penguin pass through everything except the ground:
            self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        }
        
        let endDie = SKAction.runBlock {
            // Turn gravity back on:
            self.physicsBody?.affectedByGravity = true
        }
        
        self.dieAnimation = SKAction.sequence([
            startDie,
            // Scale the penguin bigger:
            SKAction.scaleTo(2.2, duration: 0.5),
            // Use the waitForDuration action to provide a short pause:
            SKAction.waitForDuration(0.5),
            // Rotate the penguin on to his back:
            SKAction.rotateToAngle(3, duration: 1.5),
            SKAction.waitForDuration(0.5),
            endDie
            ])
    }
    
    func update() {
        // If we are flapping, apply a new force to push Boris higher.
        if (self.flapping) {
            var forceToApply = maxFlappingForce
            
            // Apply less force if Boris is above position 600
            if (position.y > 600) {
                // We will apply less and less force the higher Boris goes.
                // These next three lines determine just how much force to mitigate:
                let percentageOfMaxHeight = position.y / maxHeight
                let flappingForceSubtraction = percentageOfMaxHeight * maxFlappingForce
                forceToApply -= flappingForceSubtraction
            }
            // Apply the final force:
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: forceToApply))
        }
        
        // We need to limit Boris's top speed as he shoots up the y-axis.
        // This prevents him from building up enough momentum to shoot high
        // over our max height. We are bending the physics to improve the gameplay:
        if (self.physicsBody?.velocity.dy > 300) {
            self.physicsBody?.velocity.dy = 300
        }
        
        // Set a constant velocity to the right:
        self.physicsBody?.velocity.dx = self.forwardVelocity
    }
    
    // Begin the flapping animation, and set the flapping property to true:
    func startFlapping() {
        if self.health <= 0 { return }
        
        self.removeActionForKey("soarAnimation")
        self.runAction(flyAnimation, withKey: "flapAnimation")
        self.flapping = true
    }
    
    // Start the soar animation, and set the flapping property to false:
    func stopFlapping() {
        if self.health <= 0 { return }
        
        self.removeActionForKey("flapAnimation")
        self.runAction(soarAnimation, withKey: "soarAnimation")
        self.flapping = false
    }
    
    func takeDamage() {
        // If currently invulnerable or damaged, return out of the function:
        if self.invulnerable || self.damaged { return }
        // Set the damaged state to true after being hit:
        self.damaged = true
        
        // Remove one from our health pool
        self.health--
        
        if self.health == 0 {
            // If we are out of health, run the die function:
            die()
        }
        else {
            // Run the take damage animation:
            self.runAction(self.damageAnimation)
        }
        
        // Play the hurt sound:
        self.runAction(hurtSound)
    }
    
    func starPower() {
        // Remove any existing star powerup animation:
        // (if the player is already under the power of another star)
        self.removeActionForKey("starPower")
        // Grant great forward speed:
        self.forwardVelocity = 400
        // Make the player invulnerable:
        self.invulnerable = true
        // Create a sequence to scale the player larger,
        // wait 8 seconds, then scale back down and turn off
        // invulnerability, returning the player to normal speed:
        let starSequence = SKAction.sequence([
            SKAction.scaleTo(1.5, duration: 0.3),
            SKAction.waitForDuration(8),
            SKAction.scaleTo(1, duration: 1),
            SKAction.runBlock {
                self.forwardVelocity = 200
                self.invulnerable = false
            }
            ])
        // Execute the sequence:
        self.runAction(starSequence, withKey: "starPower")
        // Play the powerup sound:
        self.runAction(powerupSound)
    }
    
    func die() {
        // Make sure the player is fully visible:
        self.alpha = 1
        // Remove all animations:
        self.removeAllActions()
        // Run the die animation:
        self.runAction(self.dieAnimation)
        // Prevent any further upward movement:
        self.flapping = false
        // Stop forward movement:
        self.forwardVelocity = 0
        // Alert the GameScene:
        if let gameScene = self.parent?.parent as? GameScene {
            gameScene.gameOver()
        }
    }
    
    func onTap() {}
}
