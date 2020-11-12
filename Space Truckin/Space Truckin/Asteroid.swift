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
    
    // setup physics detection
    let asteroidCategory : UInt32 = 0x1 << 1
    let truckCategory : UInt32 = 0x1 << 0
    
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
        let numItems = Int.random(in: 2...4)
        let quantity = 20
        let point = self.sprite.position
        //TODO
        let asteroidItemTypes = [ItemType.Precious, ItemType.Nuclear, ItemType.Stone]

        let item = Item(type: asteroidItemTypes.randomElement()!, value: 20)
        for i in 0..<numItems {
            let drop = DroppedItem(sprite: SKSpriteNode(imageNamed: DroppedItem.filenames[item.type.rawValue]), item: item, speed: 120, direction: CGFloat(i) * CGFloat(Double.pi) / 2)

            drop.spawn(at: CGPoint(x: point.x + 10 * CGFloat(i), y: point.y + 10 * CGFloat(i)))
            (self.sprite.parent as? GameScene)!.objectsInScene[drop.sprite.name] = drop
            self.sprite.parent!.addChild(drop.sprite)
        }
    }
    
    @objc func deleteSelf () {
        dropItems(at: self.sprite.position)
        self.sprite.removeFromParent()
    }
}
