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

class Asteroid : SpaceObject {
    
    required init(instance: SpaceObject) {
        guard let _ = instance as? Asteroid else {fatalError()}
        let sprite = instance.sprite.copy() as? SKSpriteNode
        
        super.init(instance.durability, sprite!, instance.xRange, instance.yRange, instance.inventory, instance.speed, instance.rotation, instance.targetAngle, instance.boostSpeed)
    }

    
    // convenience for non-moving objects
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0, 0)
        sprite.name = "asteroid"
    }
    
    override init (_ durability: Int,
          _ sprite: SKSpriteNode,
          _ xRange: (CGFloat, CGFloat),
          _ yRange: (CGFloat, CGFloat),
          _ inventory: Inventory,
          _ speed: CGFloat,
          _ rotation: CGFloat,
          _ targetAngle: CGFloat,
          _ boostSpeed: CGFloat) {
        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, boostSpeed)
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        knockback = 0
        sprite.name = "asteroid"
        
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
        //if !destroyed{ //Needed to prevent bumping around the explosion
        let coeff: CGFloat = obj.knockback
        let newNormal = reboundVector(from: contact.contactPoint).mult(by: coeff)

        //print("asteroid on impact with \(obj.sprite.name!)")
        if obj.sprite.isHidden {
            
        } else if obj.sprite.name == "item" {
            
        } else if obj.sprite.name == "asteroid" {
            
        } else if obj.sprite.name == "debris" {
            
        //Capsule vs Rad Missile Collision
        } else if obj.sprite.name == "rad_missile" {
            self.addForce(vec: obj.lastVector.normalized().mult(by: coeff))

            if takeDamage(obj.impactDamage) {
                onDestroy()
            }
        } else {
            self.addForce(vec: newNormal)
            if takeDamage(obj.impactDamage) {
                onDestroy()
            }
        }
    }
    
    override func onDestroy() {
        destroyed = true
        explode()
        
        let rnum: Int = Int.random(in: 0...3)
        for _ in 0...rnum {
            dropItem(at: self.sprite.position)
        }
        
        let duration = Double.random(in: 0.4...0.7)
        let removeDate = Date().addingTimeInterval(duration)
        let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    
    @objc func deleteSelf () {

        self.sprite.removeFromParent()
    }
}


//class RadioactiveAsteroid: Asteroid {
//    let radGlow = SKEmitterNode(fileNamed: "radioactiveDecay")
//    
//    override init(_ durability: Int, _ sprite: SKSpriteNode, _ xRange: (CGFloat, CGFloat), _ yRange: (CGFloat, CGFloat), _ inventory: Inventory, _ speed: CGFloat, _ rotation: CGFloat, _ targetAngle: CGFloat, _ collisionCategory: UInt32, _ testCategory: UInt32, _ boostSpeed: CGFloat) {
//        
//        
//        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, collisionCategory, testCategory, boostSpeed)
//        radGlow?.zPosition = sprite.zPosition - 1
//    }
//    
//    required init(instance: SpaceObject) {
//        guard let _ = instance as? RadioactiveAsteroid else {fatalError()}
//        
//        let sprite = instance.sprite.copy() as? SKSpriteNode
//        if let name = sprite?.name {
//            sprite?.name = name + "c"
//        }
//        
//        super.init(instance.durability, sprite!, instance.xRange, instance.yRange, instance.inventory, instance.speed, instance.rotation, instance.targetAngle, instance.collisionCategory, instance.testCategory, instance.boostSpeed)
//        
//    }
//    
//    override func update(by delta: CGFloat) {
//        radGlow?.position = sprite.position
//        super.update(by: delta)
//    }
//    
//    
//    override func getChildren() -> [SKNode?] {
//        return super.getChildren() + [radGlow]
//    }
//}
