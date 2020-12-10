//
//  SpaceStation.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/18/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

class SpaceStation: SpaceObject {
    var hullSprite: SKSpriteNode
    var armAngle: CGFloat = 0
    var dimension: CGFloat
    var stationMenu: SpaceStationScreen
    var area: Area!
    
    convenience init() {
        self.init(-1, SKSpriteNode(imageNamed: "space_station_arm_1"), (2000, 2000), (500, 500), Inventory(), 0, 30, 0, 100)
    }
    
    override init(_ durability: Int, _ sprite: SKSpriteNode, _ xRange: (CGFloat, CGFloat), _ yRange: (CGFloat, CGFloat), _ inventory: Inventory, _ speed: CGFloat, _ rotation: CGFloat, _ targetAngle: CGFloat, _ boostSpeed: CGFloat) {
        hullSprite = SKSpriteNode(imageNamed: "space_station_hull_1")
        dimension = CGFloat.random(in: xRange.0...xRange.1)
        hullSprite.size = CGSize(width: dimension, height: dimension)
        sprite.size = CGSize(width: dimension, height: 1.5 * dimension)
        sprite.zRotation = armAngle
        
        let margin: CGFloat = 0.8
        //sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width * 0.2, height: margin * sprite.size.height))
        let physicsBodyPosition = CGPoint(x: sprite.position.x, y: sprite.position.y - sprite.size.height * 0.39)
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height * 0.03, center: physicsBodyPosition)
        hullSprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hullSprite.size.width * margin, height: margin * hullSprite.size.height))
        sprite.zPosition = 10
        hullSprite.zPosition = sprite.zPosition + 1
        hullSprite.physicsBody?.isDynamic = false
        hullSprite.physicsBody?.categoryBitMask = CollisionCategories.SPACEOBJECT
        hullSprite.physicsBody?.contactTestBitMask = CollisionCategories.SPACEOBJECT
        hullSprite.physicsBody?.collisionBitMask = 0
        
        stationMenu = SpaceStationScreen()
        
        super.init(durability, sprite, xRange, yRange, inventory, 0, rotation, targetAngle, boostSpeed)
        sprite.physicsBody?.isDynamic = false
        
        isImportant = true
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.name = "station_arm"
        hullSprite.name = "station"
        sprite.position = spawnPoint
        hullSprite.position = spawnPoint
        
        
        // so the arm is facing to the right at spawn
        sprite.zRotation = 1.57
        
        // setup arm to rotate at random speed
        let spinSpeed = Double.random(in: 2...5) * Double(dimension / 25)
        var action  = [SKAction]()
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: spinSpeed))
        let delay = SKAction.wait(forDuration: 4)
        action.append(delay)
        action.append(rotateAction)
        // run rotation
        sprite.run(SKAction.sequence(action))
    }
    
    func dockHead(_ piece: TruckPiece){
        sprite.isPaused = true
        piece.setBoost(b: false)
        piece.dockPiece()
        if piece.isHead{
            piece.dockedStation = self
            piece.inventory.items[ItemType.Oxygen] = piece.inventory.getMaxCapacity(for: ItemType.Oxygen)
        }
        //set head
        //show screen
        print("DOCKED")
    }
    
    
    func undock(){
        sprite.isPaused = false
        //remove head reference?
        //hide screen
        print("UNDOCKED")

    }
    
    override func move(by delta: CGFloat) {
        moveForward(by: delta)
    }
    
    override func update(by delta: CGFloat) {
        hullSprite.position = sprite.position
    }
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        let coeff: CGFloat = 4

        let newNormal = reboundVector(from: contact.contactPoint).mult(by: coeff)
        
        if obj.sprite.isHidden {
            print("skipped hidden collision")
        } else if obj.sprite.name == "item" {
            
        } else if obj.sprite.name == "asteroid" {
            
        } else if obj.sprite.name == "debris" {
                
        } else if obj.sprite.name == "capsule"{
            let piece = obj as! TruckPiece
            if !piece.docked {
                if piece.isHead && piece.releashingFrames == 0{
                    dockHead(piece)
                }
                if sprite.isPaused && piece.getFirstPiece().docked{
                    piece.dockPiece()
                }
            }
        }
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [hullSprite]
    }
}
