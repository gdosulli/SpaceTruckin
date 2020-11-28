//
//  RivalTruck.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/23/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

/*
  - - - Idea Vomit - - -
 Potential Enemy Types/Behaviors:
 
    Rival Mining Rig:
        Large drill head with 1-3 storage followers
        Targets nearby asteroids and storable items
        Very durable and capable of ramming if attacked
        Slow turn/movespeed but high boost speed
    
    Space Pirates - stagecoach train robbery style:
        Leader could start by towing harassers and deploy them during combat
        At least 1 leader capable of towing
            Targets lost_capsules and runs once full
            Tries to match speed and direction of player
        Motley of smaller harrassers
            (Types: Rammer - no damage strong knockback,
            Stunner - no damage no knockback but if it impacts the front capsule it will stun it,
            Puller - attaches a leash to a lost_capsule or (player) capsule and tries to pull it towards the leader)
 
    Space Cops:
        Scans ships for black market goods
        Attacks lawbreakers with EMP torpedos
    
    Smuggler:  (Firefly reference)
        Fast rare ship that tries to avoid you or run to a station if you chase
        Destroying it gives a unique dashboard item which would be the plastic dinosaurs Wash plays with
 
    Aliens:
    
    
    Space Virus:
        
    Entropy Waves: funsies
        Space time distortions
        Speed up, slow down, teleport strangely idk
 
    Space Whales:
        Consume space whale food (some cool mineral or space biomass) and will try to eat the capsule that are storing space whale food
        Space cops defend them as an endangered species
        Space whale oil is a valuable commodity on black market
        Only way to sell oil is to haul a dead whale to a station with harpoons/tractor beam
 
    Slavers/Alien probers:
        Stun any nearby ships and tries to haul them home
 
    Rifts:
        Strange wormhole which has a secret subarea on the other end
        Looks like almost nothing until you get close, reflects whatever is close to it?
 
    Space Storm type shit:
        reverse everything on screen, all controls etc
 */


class RivalTruckPiece: TruckPiece {
    init(sprite: SKSpriteNode, xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), speed: CGFloat, rotation: CGFloat) {
        
        super.init(3, sprite, nil, xRange, yRange, Inventory(), speed, rotation, 0, speed)
        sprite.name = "rival_capsule"
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    
    //Returns a list of connected rival truckPieces
    static func generateChain(with numFollowers: Int, holding itemList: [ItemType]) -> [RivalTruckPiece]{
        
        let rival_speed = CGFloat(200)
        
        let head = RivalTruckPiece.init(sprite: SKSpriteNode(imageNamed: "rival_truck_cab"), xRange: (1.5,1.0), yRange: (1.5,1.0), speed: rival_speed, rotation: 0)//M
        head.isHead = true
        var truckList = [head]
        for i in 0..<numFollowers{
            let piece = RivalTruckPiece.init(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), xRange: (1.0,1.0), yRange: (1.0,1.0), speed: rival_speed, rotation: 0)//M
            piece.addToChain(adding: truckList[i])
            
            if let chosenItemType = itemList.randomElement(){
                _ = piece.inventory.addItem(item: Item.init(type: chosenItemType, value: piece.inventory.maxCapacities[chosenItemType]!))
            }
            truckList.append(piece)
        }
        return truckList
    }
    
    override func update(by delta: CGFloat) {
        super.update(by: delta)
    }
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        
        var collisionVector = contact.contactNormal
//        if self.sprite === contact.bodyB.node{
//            print("FLIP RIVAL")
//            collisionVector.dx *= -1
//            collisionVector.dy *= -1
//        }
        
        //Rival Capsule vs Capsule collision
        if (obj.sprite.name?.starts(with: "capsule"))! {
            var newNormal = CGVector(dx: 10 * collisionVector.dx, dy: 10 * collisionVector.dy)
            self.addForce(vec: newNormal)
        
        
        //Rival Capsule vs Asteroid and Debris collision
        } else if (obj.sprite.name?.starts(with: "asteroid"))! || (obj.sprite.name?.starts(with: "debris"))! {
            let newNormal = CGVector(dx: -10 * collisionVector.dx, dy: -10 * collisionVector.dy)
            self.addForce(vec: newNormal)
            durability -= obj.impactDamage
            print("oof ouch \(durability)")
            if durability <= 0 {
                onDestroy()
            }
    
            
        //Rival Capsule vs Lost Capsule collision
        } else if obj.sprite.name == "lost_capsule" {
            addToChain(adding: (obj as? TruckPiece)!)
            
        //Capsule vs SpaceStation Collision --- needed or not?
        }
    }
}
