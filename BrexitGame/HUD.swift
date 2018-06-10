//
//  HUD.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class HUD: SKNode {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"hud.atlas")
    var heartNodes:[SKSpriteNode] = []
    let coinCountText = SKLabelNode(text: "000000")
    let restartButton = SKSpriteNode()
    let menuButton = SKSpriteNode()
    
    func createHudNodes(screenSize:CGSize) {
        // --- Create the coin counter ---
        // First, create an position a bronze coin icon for the coin counter:
        let coinTextureAtlas:SKTextureAtlas = SKTextureAtlas(named:"goods.atlas")
        let coinIcon = SKSpriteNode(texture: coinTextureAtlas.textureNamed("coin-gold.png"))
        // Size and position the coin icon:
        let coinYPos = screenSize.height - 23
        coinIcon.size = CGSize(width: 26, height: 26)
        coinIcon.position = CGPoint(x: 23, y: coinYPos)
        // Configure the coin text label:
        coinCountText.fontName = "AvenirNext-HeavyItalic"
        coinCountText.color = UIColor.black
        coinCountText.position = CGPoint(x: 41, y: coinYPos)
        
        // These two properties allow you to align the text relative to the SKLabelNode's position:
        coinCountText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        coinCountText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        // Add the text label and coin icon to the HUD:
        self.addChild(coinCountText)
        self.addChild(coinIcon)
        
        // Create three heart nodes for the life meter:
        var index = 0
        repeat {
            let newHeartNode = SKSpriteNode(texture: textureAtlas.textureNamed("heart-full.png"))
            newHeartNode.size = CGSize(width: 46, height: 40)
            // Position the heart nodes in a row, just below the coin counter:
            let xPos = CGFloat(index * 60 + 33)
            let yPos = screenSize.height - 66
            newHeartNode.position = CGPoint(x: xPos, y: yPos)
            // Keep track of the nodes in an array property on HUD:
            heartNodes.append(newHeartNode)
            // Add the heart nodes to the HUD:
            self.addChild(newHeartNode)
            index += 1
        } while index < 3
        
        // Add the restart and menu button textures to the nodes:
        restartButton.texture = textureAtlas.textureNamed("button-restart.png")
        menuButton.texture = textureAtlas.textureNamed("button-menu.png")
        // Assign node names to the buttons:
        restartButton.name = "restartGame"
        menuButton.name = "returnToMenu"
        // Position the button node:
        let centerOfHud = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        restartButton.position = centerOfHud
        menuButton.position = CGPoint(x: centerOfHud.x - 140, y: centerOfHud.y)
        // Size the button nodes:
        restartButton.size = CGSize(width: 70, height: 70)
        menuButton.size = CGSize(width: 70, height: 70)
    }
    
    func showButtons() {
        // Set the button alpha to 0:
        restartButton.alpha = 0
        menuButton.alpha = 0
        // Add the button nodes to the HUD:
        self.addChild(restartButton)
        self.addChild(menuButton)
        // Fade in the buttons:
        let fadeAnimation = SKAction.fadeAlpha(to: 1, duration: 0.4)
        restartButton.run(fadeAnimation)
        menuButton.run(fadeAnimation)
    }
    
    func setCoinCountDisplay(newCoinCount:Int) {
        // We can use the NSNumberFormatter class to pad leading 0's onto the coin count:
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 6
        let coinStr = String(newCoinCount)
        // Update the label node with the new coin count:
        coinCountText.text = coinStr
    }
    
    func setHealthDisplay(newHealth:Int) {
        // Create a fade SKAction to fade out any lost hearts:
        let fadeAction = SKAction.fadeAlpha(to: 0.2, duration: 0.3)
        // Loop through each heart and update its status:
        var index = 0
        repeat {
            if index < newHealth {
                // This heart should be full red:
                heartNodes[index].alpha = 1
            }
            else {
                // This heart should be faded:
                heartNodes[index].run(fadeAction)
            }
            index += 1
        } while index < heartNodes.count
        
    }
}
