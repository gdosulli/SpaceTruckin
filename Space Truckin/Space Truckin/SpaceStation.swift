//
//  SpaceStation.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/18/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class SpaceStation: SpaceObject {
    var armSprite: SKSpriteNode
    var armAngle: CGFloat = 0
    
    convenience init() {
                
        self.init(-1, SKSpriteNode(imageNamed: "space_station_hull_1"), (2000, 2000), (500, 500), Inventory(), 25, 30, 0, CollisionCategories.SPACE_STATION_CATEGORY, CollisionCategories.TRUCK_CATEGORY, 100)
    }
    
    override init(_ durability: Int, _ sprite: SKSpriteNode, _ xRange: (CGFloat, CGFloat), _ yRange: (CGFloat, CGFloat), _ inventory: Inventory, _ speed: CGFloat, _ rotation: CGFloat, _ targetAngle: CGFloat, _ collisionCategory: UInt32, _ testCategory: UInt32, _ boostSpeed: CGFloat) {
        
        armSprite = SKSpriteNode(imageNamed: "space_station_arm_1")
        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, collisionCategory, testCategory, boostSpeed)
        

    }
//    required init(instance: SpaceObject) {
//        armSprite = SKSpriteNode(imageNamed: "space_station_arm_1")
//         super.init(instance: instance)
//     }
     
    
    override func spawn(at spawnPoint: CGPoint) {
        let dimension = CGFloat.random(in: xRange.0...xRange.1)
        sprite.size = CGSize(width: dimension, height: dimension)
        armSprite.size = CGSize(width: dimension, height: 1.5 * dimension)
        armSprite.zRotation = armAngle
        
        sprite.zPosition = 10
        armSprite.zPosition = sprite.zPosition - 1

        sprite.position = spawnPoint
        armSprite.position = spawnPoint
        // setup asteroid to rotate randomly
        let spinSpeed = Double.random(in: 2...5) * Double(dimension / 50)
        var action  = [SKAction]()
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: spinSpeed))
        action.append(rotateAction)

        // run rotation
        sprite.run(SKAction.sequence(action))
        
    }
    
    override func move(by delta: CGFloat) {
        moveForward(by: delta)
    }
    
    override func update(by delta: CGFloat) {
        armSprite.position = sprite.position
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [armSprite]
    }
}
