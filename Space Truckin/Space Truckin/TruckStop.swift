//
//  TruckStop.swift
//  Space Truckin
//
//  Created by Nathaniel Youngren on 12/9/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

class TruckStop : SpaceObject {
    let signSprite: SKSpriteNode
    var signAngle: CGFloat = 0
    var dimension: CGFloat
    var area: Area!
    var signOffset : CGFloat = 880
    var open = false
    var closeTimer = 0
    
    
    convenience init() {
        self.init(-1, SKSpriteNode(imageNamed: "truck_stop_closed"), (1800, 1800), (500, 500), Inventory(), 0, 30, 0, 100)
    }
    
    override init(_ durability: Int, _ sprite: SKSpriteNode, _ xRange: (CGFloat, CGFloat), _ yRange: (CGFloat, CGFloat), _ inventory: Inventory, _ speed: CGFloat, _ rotation: CGFloat, _ targetAngle: CGFloat, _ boostSpeed: CGFloat) {
        dimension = CGFloat.random(in: xRange.0...xRange.1)
        signSprite = SKSpriteNode(imageNamed: "truck_stop_sign")
        
        
        super.init(durability, sprite, xRange, yRange, inventory, 0, rotation, targetAngle, boostSpeed)
        
        signSprite.size = CGSize(width: dimension * 0.2, height: dimension * 0.2)
        sprite.size = CGSize(width: dimension, height: dimension)
        sprite.zRotation = signAngle

        let margin: CGFloat = 0.8
        //sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width * 0.2, height: margin * sprite.size.height))
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.height * 0.06)
        sprite.zPosition = -10
        signSprite.zPosition = sprite.zPosition + 1
        signSprite.physicsBody?.isDynamic = false
        signSprite.physicsBody?.categoryBitMask = 0
        signSprite.physicsBody?.contactTestBitMask = 0
        signSprite.physicsBody?.collisionBitMask = 0
        
        //stationMenu = SpaceStationScreen()
        
        sprite.physicsBody?.isDynamic = false
        
        isImportant = true
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.name = "truck_stop"
        signSprite.name = "truck_sign"
        sprite.position = spawnPoint
        signSprite.position = CGPoint(x: spawnPoint.x, y: spawnPoint.y)
        
        // setup arm to rotate at random speed
        let spinSpeed = Double.random(in: 2...5) * Double(dimension / 25)
        var action  = [SKAction]()
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: spinSpeed))
        let delay = SKAction.wait(forDuration: 4)
        action.append(delay)
        action.append(rotateAction)
        // run rotation
        signSprite.run(SKAction.sequence(action))
    }
    
    func toggleDoor(){
        if open {
            closeDoor()
        } else {
            openDoor()
        }
    }
    
    func shortOpen(){
        openDoor()
        closeTimer = 10
    }
    
    func openDoor(){
        sprite.texture = SKTexture(imageNamed: "truck_stop_open")
        open = true
    }
    
    func closeDoor(){
        sprite.texture = SKTexture(imageNamed: "truck_stop_closed")
        open = false
    }
    
    func dock(_ piece: TruckPiece){
        sprite.isPaused = true
        piece.setBoost(b: false)
        piece.dockedStation = self
        piece.dockPiece()
        piece.inventory.items[ItemType.Oxygen] = piece.inventory.getMaxCapacity(for: ItemType.Oxygen)
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
        signAngle = signSprite.zRotation + CGFloat.pi/2
        signSprite.position = CGPoint(x: sprite.position.x + signOffset*cos(signAngle), y: sprite.position.y+signOffset*sin(signAngle))
        if closeTimer > 0 {
            closeTimer -= 1
            if closeTimer == 0 {
                closeDoor()
            }
        }
    }
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        let coeff: CGFloat = 4

        let newNormal = reboundVector(from: contact.contactPoint).mult(by: coeff)
        
        if obj.sprite.isHidden {
            //print("skipped hidden collision")
        } else if obj.sprite.name == "item" {
            
        } else if obj.sprite.name == "asteroid" {
            
        } else if obj.sprite.name == "debris" {
                
        } else if obj.sprite.name == "capsule"{
            let piece = obj as! TruckPiece
            if !piece.docked {
                if piece.isHead && piece.releashingFrames == 0{
                    dock(piece)
                    shortOpen()
                }
                if sprite.isPaused && piece.getFirstPiece().docked{
                    piece.dockPiece()
                    shortOpen()
                    
                    if piece.getLastPiece() === piece {
                        showMenu(with: piece.getFirstPiece())
                    }
                }
            }
        }
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [signSprite]
    }
    
    
    
    func showMenu(with head: TruckPiece) {
        
        // TODO: get this from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menuView = storyboard.instantiateViewController(withIdentifier: "stationMenu") as! SpaceStationMenuView
        menuView.playerTruckHead = head
        let scene = sprite.parent as! AreaScene
        let vc = scene.viewController!
        
        vc.present(menuView, animated: true, completion: nil)
    }
    
    
}
