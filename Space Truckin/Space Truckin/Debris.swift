//
//  Debris.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/30/20.

import Foundation
import SpriteKit
import GameplayKit

class Debris : SpaceObject {
    
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0, 0)
        sprite.name = "debris"
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.name = "debris"
        // set random asteroid size
        let dimension = CGFloat.random(in: xRange.0...xRange.1)
        sprite.size = CGSize(width: dimension, height: dimension)
        // add physics and collision detection to asteroid
        // create a rectangle that's a bit smaller than the image, to work for the collider
        let margin: CGFloat = 0.3
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
        let coeff: CGFloat = obj.knockback
        let newNormal = reboundVector(from: contact.contactPoint).mult(by: coeff)

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
        if !destroyed {
            destroyed = true
            explode()
        
            let rnum: Int = Int.random(in: 0...3)
            for _ in 0...rnum {
                dropItem(at: self.sprite.position)
            }
            
            
            let duration = Double.random(in: 0.7...1.3)
            expand(amount: 0.2, duration: duration/3)
            let removeDate = Date().addingTimeInterval(duration)
            let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
//    func dropItems(at point: CGPoint) {
//        let numItems = Int.random(in: 2...4)
//        let quantity = 20
//        let point = self.sprite.position
//        let spaceJunkItemTypes = [ItemType.Scrap, ItemType.Oxygen, ItemType.Water]
//
//        let item = Item(type: spaceJunkItemTypes.randomElement()!, value: 20)
//        for i in 0..<numItems {
//            let drop = DroppedItem(sprite: SKSpriteNode(imageNamed: DroppedItem.filenames[item.type.rawValue]), item: item, speed: 120, direction: CGFloat(i) * CGFloat(Double.pi) / 2)
//
//            drop.spawn(at: CGPoint(x: point.x + 10 * CGFloat(i), y: point.y + 10 * CGFloat(i)))
//            (self.sprite.parent as? GameScene)!.objectsInScene[drop.sprite] = drop
//            self.sprite.parent!.addChild(drop.sprite)
//        }
//    }
    
    @objc func deleteSelf() {
        self.sprite.removeFromParent()
    }
}
