//
//  MenuScene.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
 
    let textureAtlas:SKTextureAtlas =
    SKTextureAtlas(named:"hud.atlas")
    let startButton = SKSpriteNode()
    
    override func didMoveToView(view: SKView) {
        // Position nodes from the center of the scene:
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Set a sky color:
        self.backgroundColor = UIColor.whiteColor()
        // Add the background image:
        let backgroundImage = SKSpriteNode(imageNamed: "Background-menu")
        backgroundImage.size = CGSize(width: 512, height: 384)
        self.addChild(backgroundImage)
        
        
        // Build the start game button:
        startButton.texture = textureAtlas.textureNamed("button.png")
        startButton.size = CGSize(width: 150, height: 70)
        startButton.name = "StartBtn"
        startButton.position = CGPoint(x: 0, y: -40)
        self.addChild(startButton)
  
        
        // Pulse the start button in and out gently:
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlphaTo(0.7, duration: 0.9),
            SKAction.fadeAlphaTo(1, duration: 0.9),
            ])
        startButton.runAction(
            SKAction.repeatActionForever(pulseAction))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in (touches ) {
            let location = touch.locationInNode(self)
            let nodeTouched = nodeAtPoint(location)
            
            if nodeTouched.name == "StartBtn" {
                self.view?.presentScene(GameScene(size: self.size))
            }
        }
    }
}

