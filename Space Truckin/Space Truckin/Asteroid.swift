//
//  Asteroid.swift
//  Space Truckin
//
//  Created on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Asteroid : SpaceObject, Copyable {
    
    
    required init(instance: Asteroid) {
        let sprite = instance.sprite.copy() as? SKSpriteNode
        if let name = sprite?.name {
            sprite?.name = name + "c"
        }
        
        super.init(instance.durability, sprite!, instance.xRange, instance.yRange, instance.inventory, instance.speed, instance.rotation, instance.targetAngle, instance.collisionCategory, instance.testCategory, instance.boostSpeed)
    }

    
    // convenience for non-moving objects
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0, CollisionCategories.ASTEROID_CATEGORY, CollisionCategories.TRUCK_CATEGORY, 0)
    }
    
    override init (_ durability: Int,
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
        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, collisionCategory, testCategory, boostSpeed)
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        // set random asteroid size
        let dimension = CGFloat.random(in: xRange.0...xRange.1)
        sprite.size = CGSize(width: dimension, height: dimension)
        
        // add physics and collision detection to asteroid
        // create a rectangel that's a bit smaller than the image, to work for the collider
        let margin: CGFloat = 0.5
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: dimension-(margin * dimension), height: dimension-(margin * dimension)))
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = self.collisionCategory
        sprite.physicsBody?.contactTestBitMask = self.testCategory
        sprite.physicsBody?.collisionBitMask = 0
        
        // set random initial position
        sprite.position = spawnPoint
        
        // setup asteroid to rotate randomly
        let spinSpeed = Double.random(in: 2...5) * Double(dimension / 100)
        var action  = [SKAction]()
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: spinSpeed))
        action.append(rotateAction)
        
        // run rotation
        sprite.run(SKAction.sequence(action))
    }
    
    //TODO: May need to make normal vector direction a field in order to know whether to flip vector or not
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        let newNormal = CGVector(dx: 10 * contact.contactNormal.dx, dy: 10 * contact.contactNormal.dy)
        self.addForce(vec: newNormal)
        durability -= obj.impactDamage
        if durability <= 0 {
            self.onDestroy()
        }
    }
    
    override func onDestroy() {
        if !destroyed {
            destroyed = true
            explode()
            let duration = Double.random(in: 0.4...0.7)
            let removeDate = Date().addingTimeInterval(duration)
            let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            
        }
        
    }
    
    func dropItems(at point: CGPoint) {
        let numItems = Int.random(in: 1...4)
        
        let point = self.sprite.position
        
        let s = sprite.parent as? AreaScene
        if let scene = s {
        
            for i in 0..<numItems {
                for k in inventory.items.keys {
                    if let q = inventory.items[k] {
                        if q > 0 {
                            let item = Item(type: k, value: q)
                            let drop = DroppedItem(sprite: SKSpriteNode(imageNamed: DroppedItem.filenames[item.type.rawValue]), item: item, speed: 120, direction: CGFloat(i) * CGFloat(Double.pi) / 2)

                            drop.spawn(at: CGPoint(x: point.x + 10 * CGFloat(i), y: point.y + 10 * CGFloat(i)))
                            
                            scene.currentArea.addObject(obj: drop)
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func deleteSelf () {
        dropItems(at: self.sprite.position)
        self.sprite.removeFromParent()
    }
}
