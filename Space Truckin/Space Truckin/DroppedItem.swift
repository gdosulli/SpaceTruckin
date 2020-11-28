//
//  ItemDrop.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/11/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit


let defaultItem = Item(type: .Oxygen, value: 0)

class DroppedItem: SpaceObject {
    var item: Item
    var lifeSpan: TimeInterval = 300.0
    var collected = false
    
    static let filenames = ["Inventory_ScrapMetal", "Inventory_radioactiveMaterial",  "Inventory_PreciousMetal", "Inventory_water","Inventory_Oxygen", "Inventory_Stone" ]
    
    init(sprite s1: SKSpriteNode, item i1: Item, speed: CGFloat, direction: CGFloat) {
        self.item = i1
        super.init(1, s1, (200,50), (200,50), Inventory(), speed, 3.14, direction, 0)
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    
//    required init(instance: SpaceObject) {
//        self.item = defaultItem
//        super.init(instance: instance)
//     }
     
    
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.name = "item"
        sprite.size = CGSize(width: xRange.0, height: yRange.0)
        
        let margin: CGFloat = 0.5
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: xRange.0-(margin * xRange.0), height: yRange.0-(margin * yRange.0)))
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = self.collisionCategory
        sprite.physicsBody?.contactTestBitMask = self.testCategory
        sprite.physicsBody?.collisionBitMask = 0
        
        // set random initial position
        sprite.position = spawnPoint
        
        // setup asteroid to rotate randomly
        let spinSpeed = 1
        var action  = [SKAction]()
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: TimeInterval(spinSpeed)))
        action.append(rotateAction)
        
        // run rotation
        sprite.run(SKAction.sequence(action))
        
    }
    
    override func update(by delta: CGFloat) {
        lifeSpan -= TimeInterval(delta)
        if lifeSpan < 0.0 {
            // Item disappears
            print("poof")
        }
    }
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        //TODO add item to player inventory w/ animation
        //possibly make func to pull into inventory
        
        // I want every piece to be able to collect items, but have them
        if obj.sprite.name == "capsule" || obj.sprite.name == "rival_capsule" {
            if !collected, let truckPiece = obj as? TruckPiece {
                
                var nextPiece: TruckPiece? = truckPiece.getFirstPiece()
                while let p = nextPiece {
                    let add = p.inventory.addItem(item: item)
                    if  add.0 {
                        //set current item to p.inventory.addItem().1
                        if let reducedItem = add.1 {
                            self.item = reducedItem
                            //print("\(item.value) \(item.type) left after snaggin")
                        } else {
                            collected = true
                           // TODO add animation from current position to capsule
                           let duration : TimeInterval = 0.2
                           var action  = [SKAction]()
                           action.append(SKAction.move(to: CGPoint(x: p.sprite.position.x,
                                                                   y: p.sprite.position.y),
                                                       duration: duration))
                           
                           action.append(SKAction.removeFromParent())
                           sprite.run(SKAction.sequence(action))
                        }
                        //print("\(item.value) \(item.type) added to capsule")
                        return
                    }
                    nextPiece = p.followingPiece
                }
            }
        } else if obj.sprite.name == "asteroid" || obj.sprite.name == "debris" {
            onDestroy()
        }

    }
    
    override func onDestroy() {
        self.sprite.removeFromParent()
    }
}
