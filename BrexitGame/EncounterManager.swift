//
//  EncounterManager.swift
//  BrexitGame
//
//  Created by Saurabh Sikka on 29/08/16.
//  Copyright © 2016 Saurabh Sikka. All rights reserved.
//

import SpriteKit

class EncounterManager {
    // store the encounter file names
    let encounterNames: [String] = [
    "EncounterJuncker", "EncounterImmigrants", "EncounterCoins"
    ]
    // each encounter is an SKNode
    var encounters:[SKNode] = []
    var currentEncounterIndex: Int?
    var previousEncounterIndex: Int?
    
    init() {
        for encounterFileName in encounterNames {
            // Create a new node for the encounter:
            let encounter = SKNode()
            
            // Try to load this scene file into a new SKScene instance:
            if let encounterScene = SKScene(fileNamed: encounterFileName) {
                // Loop through each placeholder, spawn the appropriate game object:
                for placeholder in encounterScene.children {
                    if let node = placeholder as SKNode! {
                        switch node.name! {
                        case "Immigrant":
                            let immigrant = Immigrant()
                            immigrant.spawn(parentNode: encounter, position: node.position)
                        case "Juncker":
                            let juncker = Juncker()
                            juncker.spawn(parentNode: encounter, position: node.position)
                        case "Blade":
                            let blade = Blade()
                            blade.spawn(parentNode: encounter, position: node.position)
                        case "Cameron":
                            let cameron = Cameron()
                            cameron.spawn(parentNode: encounter, position: node.position)
                        case "Gove":
                            let gove = Gove()
                            gove.spawn(parentNode: encounter, position: node.position)
                        case "GoldCoin":
                            let coin = Coin()
                            coin.spawn(parentNode: encounter, position: node.position)
                            coin.turnToGold()
                        case "BronzeCoin":
                            let coin = Coin()
                            coin.spawn(parentNode: encounter, position: node.position)
                        case "Star":
                            let star = Star()
                            star.spawn(parentNode: encounter, position: node.position)
                        default:
                            print("Encounter node name not found: \(String(describing: node.name))")
                        }
                    }
                }
            }
            
            // Add the populated encounter node to the encounter array:
            encounters.append(encounter)
            // Save initial sprite positions for this encounter:
            saveSpritePositions(node: encounter)
        }
    }
    
    // This function will append all of the encounter nodes
    // to the world node from our GameScene:
    func addEncountersToWorld(world:SKNode) {
        for index in 0 ... encounters.count - 1 {
            // Spawn the encounters behind the action, with
            // increasing height so they don't collide with each other:
            encounters[index].position = CGPoint(x: -2000, y: index * 1000)
            world.addChild(encounters[index])
        }
    }
    
    func placeNextEncounter(currentXPos:CGFloat) {
        // Count the encounters in a random ready type (Uint32):
        let encounterCount = UInt32(encounters.count)
        // The game requires at least 3 encounters to function properly,
        // so exit this function if there are less than 3
        if encounterCount < 3 { return }
        
        // We need to make sure to pick an encounter that is not
        // currently displayed on the screen.
        var nextEncounterIndex:Int?
        var trulyNew:Bool?
        // The current encounter and the directly previous encounter
        // can potentially be on the screen at this time.
        // Pick until we get a new encounter
        while trulyNew == false || trulyNew == nil {
            // Pick a random encounter to set next:
            nextEncounterIndex = Int(arc4random_uniform(encounterCount))
            // To begin, assert that this is a new encounter:
            trulyNew = true
            // Test if it is a current encounter:
            if let currentIndex = currentEncounterIndex {
                if (nextEncounterIndex == currentIndex) {
                    trulyNew = false
                }
            }
            // Test if it is the directly previous encounter:
            if let previousIndex = previousEncounterIndex {
                if (nextEncounterIndex == previousIndex) {
                    trulyNew = false
                }
            }
        }
        
        // Keep track of the current encounter:
        previousEncounterIndex = currentEncounterIndex
        currentEncounterIndex = nextEncounterIndex
        
        // Reset the new encounter and position it ahead of the player
        let encounter = encounters[currentEncounterIndex!]
        encounter.position = CGPoint(x: currentXPos + 1000, y: 0)
        resetSpritePositions(node: encounter)
    }
    
    // Store the initial positions of the children of a node:
    func saveSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                let initialPositionValue = NSValue(cgPoint: sprite.position)
                spriteNode.userData = ["initialPosition": initialPositionValue]
                // Recursively save the positions for children of this node:
                saveSpritePositions(node: spriteNode)
            }
        }
    }
    
    // Reset all children nodes to their original position:
    func resetSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                // Remove any linear or angular velocity:
                spriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                spriteNode.physicsBody?.angularVelocity = 0
                // Reset the rotation of the sprite:
                spriteNode.zRotation = 0
                if let initialPositionVal = spriteNode.userData?.value(forKey: "initialPosition") as? NSValue {
                    // Reset the position of the sprite:
                    spriteNode.position = initialPositionVal.cgPointValue
                }
                
                // Reset positions on this node's children
                resetSpritePositions(node: spriteNode)
            }
        }
    }
}
