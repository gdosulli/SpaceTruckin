//
//  SpaceObject.swift
//  Space Truckin
//
//  Created on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


struct CollisionCategories {
    static let TRUCK_CATEGORY: UInt32 = 0x1 << 0
    static let ASTEROID_CATEGORY: UInt32 = 0x1 << 1
    static let SPACE_JUNK_CATEGORY: UInt32 = 0x1 << 2
    static let LOST_CAPSULE_CATEGORY: UInt32 = 0x1 << 3
    static let ITEM_CATEGORY: UInt32 = 0x1 << 4
}


class SpaceObject : Movable {
    var durability: Int
    var xRange: (CGFloat, CGFloat)
    var yRange: (CGFloat, CGFloat)
    var inventory: Inventory
    var collisionCategory: UInt32
    var testCategory: UInt32
    var destroyed = false
    var impactDamage = 1
    static var objectCount = 0
    
    static let explosionAnimation = [SKTexture(imageNamed: "explosion1"), SKTexture(imageNamed: "explosion2"), SKTexture(imageNamed: "explosion3"), SKTexture(imageNamed: "explosion4"),]
    
    init (_ durability: Int,
          _ sprite: SKSpriteNode,
          _ xRange: (CGFloat, CGFloat),
          _ yRange: (CGFloat, CGFloat),
          _ inventory: Inventory,
          _ speed: CGFloat,
          _ rotation: CGFloat,
          _ targetAngle: CGFloat,
          _ collisionCategory: UInt32,
          _ testCategory: UInt32,
          _ boostSpeed: CGFloat) {
        self.durability = durability
        self.xRange = xRange
        self.yRange = yRange
        self.inventory = inventory
        self.collisionCategory = collisionCategory
        self.testCategory = testCategory

        super.init(speed: speed,
                   rotation: rotation,
                   angleInRadians: targetAngle,
                   sprite: sprite, boostSpeed: boostSpeed)
        
        self.sprite.name = "\(SpaceObject.objectCount)"
        SpaceObject.objectCount += 1
        
    }
    
    // convenience for non-moving objects
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0, CollisionCategories.ASTEROID_CATEGORY, CollisionCategories.TRUCK_CATEGORY, 0)
    }
    
    
    func spawn(at spawnPoint: CGPoint) {
        fatalError("Subclasses need to implement the `spawn()` method.")
    }
    
    func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
    
    func onDestroy() {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
    
    

    
    func explode(){
        sprite.run(SKAction.animate(with: SpaceObject.explosionAnimation, timePerFrame: 0.1, resize: false, restore: false))
    }
    
    func getChildren() -> [SKNode?] {
        return [sprite]
    }
    
    func update() {
        
    }
}
