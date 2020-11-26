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


//TODO: REMOVE COLLISIONCATEGORIES (FOR THE MOST PART) SUCH THAT ALL SPACEOBJECTS HAVE THE SAME CATEGORY
struct CollisionCategories {
    static let SPACEOBJECT: UInt32 = 0x1 << 0
    static let MISC: UInt32 = 0x1 << 1
}


class SpaceObject : Movable {
    var durability: Int
    var xRange: (CGFloat, CGFloat)
    var yRange: (CGFloat, CGFloat)
    var inventory: Inventory
    var collisionCategory = CollisionCategories.SPACEOBJECT
    var testCategory = CollisionCategories.SPACEOBJECT
    var destroyed = false
    var impactDamage = 1
    var OBJECT_ID = 0
    static var objectCount = 0
    
    var isImportant = false
    
    static let explosionAnimation = [SKTexture(imageNamed: "explosion1"), SKTexture(imageNamed: "explosion2"), SKTexture(imageNamed: "explosion3"), SKTexture(imageNamed: "explosion4"),]
    
    init (_ durability: Int,
          _ sprite: SKSpriteNode,
          _ xRange: (CGFloat, CGFloat),
          _ yRange: (CGFloat, CGFloat),
          _ inventory: Inventory,
          _ speed: CGFloat,
          _ rotation: CGFloat,
          _ targetAngle: CGFloat,
          _ boostSpeed: CGFloat) {
        self.durability = durability
        self.xRange = xRange
        self.yRange = yRange
        self.inventory = inventory

        super.init(speed: speed,
                   rotation: rotation,
                   angleInRadians: targetAngle,
                   sprite: sprite, boostSpeed: boostSpeed)
        
        self.sprite.name = "\(SpaceObject.objectCount)"
        self.OBJECT_ID = SpaceObject.objectCount
        SpaceObject.objectCount += 1
        
    }
    
    // convenience for non-moving objects
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0, 0)
    }
    
//    required init(instance: SpaceObject) {
//        self.durability = instance.durability
//        self.xRange = instance.xRange
//        self.yRange = instance.yRange
//        self.inventory = instance.inventory
//        self.collisionCategory = instance.collisionCategory
//        self.testCategory = instance.testCategory
//
//        let sprite = instance.sprite.copy() as! SKSpriteNode
//        sprite.name = "\(SpaceObject.objectCount)"
//
//        super.init(speed: instance.speed, rotation: instance.rotation, angleInRadians: instance.targetAngle, sprite: sprite, boostSpeed: instance.boostSpeed)
//
//    }
    
    func spawn(at spawnPoint: CGPoint) {
        //fatalError("Subclasses need to implement the `spawn()` method.")
        print("incorrect spawn")
    }
    
    func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
    
    func onDestroy() {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
    
    func expand(amount: CGFloat, duration: TimeInterval) {
        // code for expanding
    }
    
    func explode(){
        sprite.run(SKAction.animate(with: SpaceObject.explosionAnimation, timePerFrame: 0.1, resize: false, restore: false))
    }
    
    func getChildren() -> [SKNode?] {
        return [sprite]
    }
    
    func update(by delta: CGFloat) {
        
    }
    
    
    func dropItem(at point: CGPoint) {
    let s = sprite.parent as? AreaScene
        if let scene = s {

            for k in inventory.items.keys {
                if let q = inventory.items[k] {
                    if q > 0 {
                        let item = Item(type: k, value: q)
                        let drop = DroppedItem(sprite: SKSpriteNode(imageNamed: DroppedItem.filenames[item.type.rawValue]), item: item, speed: 120, direction: CGFloat(Int.random(in: 0...4)) * CGFloat(Double.pi) / 2)
                        
                        drop.spawn(at: CGPoint(x: point.x + 10, y: point.y + 10))
                        
                        scene.currentArea.addObject(obj: drop)
                    }
                }
            }
        }
    }
        
}


protocol Copyable {
    init(instance: Self)
}

extension Copyable {
    func copy() -> Self {
        return Self.init(instance: self)
    }
}
