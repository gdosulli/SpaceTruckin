//
//  ItemDrop.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/11/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit



class ItemDrop: SpaceObject {
    var item: Item
    
    static let filenames = ["Inventory_ScrapMetal", "Inventory_radioactiveMaterial",  "Inventory_PreciousMetal", "Inventory_water","Inventory_Oxygen", "Inventory_Stone" ]
    
    init(sprite s1: SKSpriteNode, item i1: Item, speed: CGFloat, direction: CGFloat) {
        self.item = i1
        super.init(1, s1, (0.5,0.5), (0.5,0.5), Inventory(), speed, 3.14, direction, CollisionCategories.ITEM_CATEGORY, CollisionCategories.TRUCK_CATEGORY, 0)
    }
    
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.size = CGSize(width: xRange.0, height: yRange.0)
        
        //let margin: CGFloat = 0.5
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
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
}
