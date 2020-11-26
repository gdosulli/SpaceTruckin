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
    var dimension: CGFloat
    
    convenience init() {
        self.init(-1, SKSpriteNode(imageNamed: "space_station_hull_1"), (2000, 2000), (500, 500), Inventory(), 25, 30, 0, 100)
    }
    
    override init(_ durability: Int, _ sprite: SKSpriteNode, _ xRange: (CGFloat, CGFloat), _ yRange: (CGFloat, CGFloat), _ inventory: Inventory, _ speed: CGFloat, _ rotation: CGFloat, _ targetAngle: CGFloat, _ boostSpeed: CGFloat) {
        
        armSprite = SKSpriteNode(imageNamed: "space_station_arm_1")
        dimension = CGFloat.random(in: xRange.0...xRange.1)
        sprite.size = CGSize(width: dimension, height: dimension)
        armSprite.size = CGSize(width: dimension, height: 1.5 * dimension)
        armSprite.zRotation = armAngle
        let margin: CGFloat = 0.8
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width * margin, height: margin * sprite.size.height))
        armSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: armSprite.size.width * margin, height: margin * armSprite.size.height))
        sprite.zPosition = 10
        armSprite.zPosition = sprite.zPosition - 1
        
        armSprite.physicsBody?.isDynamic = false
        armSprite.physicsBody?.categoryBitMask = CollisionCategories.SPACEOBJECT
        armSprite.physicsBody?.contactTestBitMask = CollisionCategories.SPACEOBJECT
        armSprite.physicsBody?.collisionBitMask = 0
        
        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, boostSpeed)
        sprite.physicsBody?.isDynamic = false
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.name = "station"
        armSprite.name = "station_arm"
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
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [armSprite]
    }
}
