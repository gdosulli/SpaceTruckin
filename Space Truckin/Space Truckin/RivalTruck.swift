//
//  RivalTruck.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/23/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

class RivalTruckPiece: TruckPiece {
    init(sprite: SKSpriteNode, xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), speed: CGFloat, rotation: CGFloat) {
        
        super.init(3, sprite, nil, xRange, yRange, Inventory(), speed, rotation, 0, CollisionCategories.TRUCK_CATEGORY, CollisionCategories.TRUCK_CATEGORY, speed)
        sprite.name = "rival_capsule"
    }
    
    static func generateChain(with numFollowers: Int, holding itemList: [ItemType]) -> [RivalTruckPiece]{
        let head = RivalTruckPiece.init(sprite: SKSpriteNode(imageNamed: "rival_truck_cab"), xRange: (1.0,1.0), yRange: (1.0,1.0), speed: 250, rotation: 0)//M
        head.isHead = true
        var truckList = [head]
        for i in 0..<numFollowers{
            let piece = RivalTruckPiece.init(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), xRange: (1.0,1.0), yRange: (1.0,1.0), speed: 250, rotation: 0)//M
            piece.reattach(at: truckList[i])
            
            if let chosenItemType = itemList.randomElement(){
                _ = piece.inventory.addItem(item: Item.init(type: chosenItemType, value: piece.inventory.maxCapacities[chosenItemType]!))
            }
            
            truckList.append(piece)
        }
        return truckList
    }
    
    override func update(by delta: CGFloat) {
        
        super.update(by: delta)
        if let target = targetPiece {
            if getGapSize(nextPiece: target) > 300{
                breakChain(at: self)
            }
        }
    }
    
    func breakChain(at piece: TruckPiece){
        let pos = piece.targetPiece?.sprite.position
        piece.targetPiece?.followingPiece = nil
        piece.targetPiece = nil
        piece.lost = true
        let snap = EffectBubble(type: .SNAP, duration: 0.5)
        piece.sprite.parent?.addChild(snap.getChildren()[0]!)
        if let p = pos {
            snap.spawn(at: p)
        }
        
        var followPiece: TruckPiece? = piece
        while let p = followPiece {
            p.collisionCategory = CollisionCategories.LOST_CAPSULE_CATEGORY
            p.testCategory = CollisionCategories.ASTEROID_CATEGORY
            p.sprite.physicsBody?.categoryBitMask = p.collisionCategory
            p.sprite.physicsBody?.contactTestBitMask = p.testCategory
            followPiece = p.followingPiece
        }
    }
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        if (obj.sprite.name?.starts(with: "capsule"))! {
            let newNormal = CGVector(dx: -10 * contact.contactNormal.dx, dy: -10 * contact.contactNormal.dy)
            self.addForce(vec: newNormal)
        }
    }
}
