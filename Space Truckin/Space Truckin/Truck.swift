//
//  Truck.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//
import Foundation
import SpriteKit
import CoreGraphics

//Note: add thermo-stellar truckpiece for destroying wayward planets (to be used sparingly)
//Note: add wayward planets that need to be corrected with thermo-stellar device

class TruckPiece: SpaceObject {
    
    static let drillAnimation = [SKTexture(imageNamed: "drill1"), SKTexture(imageNamed: "drill2"), SKTexture(imageNamed: "drill3"), SKTexture(imageNamed: "drill4"), SKTexture(imageNamed: "drill5"), SKTexture(imageNamed: "drill6"), SKTexture(imageNamed: "drill7")]
    
    let thruster: SKEmitterNode = SKEmitterNode(fileNamed: "sparkEmitter")!
    var distanceToHead: CGFloat = 0.0
    var targetPiece: TruckPiece?
    var followingPiece: TruckPiece?
    let mineDuration: TimeInterval = 5.0
    var lost = false
    var docked = false
    var releashingFrames = 0
    var isHead = false
    var circle = false
    var invincible = false
    var maxLeashLength = CGFloat(300)
    
    var wallet = 0
    
    convenience init(sprite s1: SKSpriteNode) {
        self.init(2, s1, nil, (1.3,1.0), (1.3,1.0), Inventory(max: 100, starting: 0), 100, 1, 0, 0)
    }
    
    convenience init(sprite s1: SKSpriteNode, inventory inv: Inventory) {
        self.init(2, s1, nil, (1.3,1.0), (1.3,1.0), inv, 100, 1, 0, 0)
    }
    
    convenience init(sprite s1: SKSpriteNode, target piece: TruckPiece) {
        self.init(2, s1, piece, (1.0,1.0), (1.0,1.0), Inventory(), piece.speed * 0.95, 1, 0, piece.boostSpeed)
        piece.followingPiece = self

    }
 
    convenience init(sprite s1: SKSpriteNode,
                     durability: Int,
                     size: CGFloat,
                     speed: CGFloat,
                     boostedSpeed: CGFloat,
                     inventory: Inventory) {

        self.init(durability, s1, nil, (size,size), (size,size), inventory, speed, 10, 0, boostedSpeed)
    }
    
    init(_ durability: Int,
    _ sprite: SKSpriteNode,
    _ targetPiece: TruckPiece?,
    _ xRange: (CGFloat, CGFloat),
    _ yRange: (CGFloat, CGFloat),
    _ inventory: Inventory,
    _ speed: CGFloat,
    _ rotation: CGFloat,
    _ targetAngle: CGFloat,
    _ boostSpeed: CGFloat) {
        
        

        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, boostSpeed)
        
        self.targetPiece = targetPiece
        
        let margin: CGFloat = 0.8
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width * margin, height: margin * sprite.size.height))
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = self.collisionCategory
        sprite.physicsBody?.contactTestBitMask = self.testCategory
        sprite.physicsBody?.collisionBitMask = 0
        thruster.zPosition = sprite.zPosition - 2
        thruster.position = sprite.position
    
        isImportant = true
        sprite.name = "capsule"
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    //
    //    required init(instance: SpaceObject) {
    //         super.init(instance: instance)
    //     }
    
    
    // ------ END OF INITIALIZATION STUFF ------ \\

     
    
    override func translate(by vector: CGPoint) {
        super.translate(by: vector)

    }
    
    //THIS FUNCTION SHOULD BE CALLED ONCE PER FRAME AND BE THE SOLE FUNCTION THAT NEEDS TO BE CALLED EVERY FRAME
    override func update(by delta: CGFloat) {
        if let piece = targetPiece {
            changeAngleTo(point: piece.sprite.position)
            if releashingFrames == 0 {
                if getGapSize(nextPiece: piece) > maxLeashLength {
                    //print("SNAP")
                    breakChain()
                }
            } else {
                releashingFrames -= 1
            }
        } else if !isHead {
            lost = true
        }
        
        
        thruster.targetNode = sprite.parent
        thruster.position = sprite.position
        
        currentAngle = sprite.zRotation - 3.14/2
        thruster.emissionAngle = currentAngle

    }
    
    //Behavior for lost pieces
    func moveLost(by delta: CGFloat){
        // deltaMod adjusts the delta to 'accelerate' and 'decelerate' to maintain follow distance of trucks
        targetAngle = sprite.zRotation - CGFloat(Double.pi / 8)
        turn(by: delta * 20)
        super.moveForward(by: delta * 0.9)
    }
    
    //TODO: Is this ever called?
    func setBoost(b: Bool) {
        boosted = b
        if b {
            speed = boostSpeed
            thruster.particleScaleSpeed = -0.2
        } else {
            speed = normalSpeed
            thruster.particleScaleSpeed = -0.4
        }
    }
    
    //TODO: Currently contains semi-hardcoded values for leashing truck pieces, some should become fields of Truck
    override func move(by delta: CGFloat) {
        var deltaMod = delta
        var turnMod = CGFloat(60)

        if docked {
            
        } else if lost {
            moveLost(by: delta)
        } else if getFirstPiece().docked {
            if !sprite.isHidden {
                deltaMod = deltaMod * 0.75
                turnMod = 300
                turn(by: delta * turnMod)
                thruster.particleBirthRate = speed * 4
                super.moveForward(by: deltaMod)
            }
        } else{
            // deltaMod adjusts the delta to 'accelerate' and 'decelerate' to maintain follow distance of trucks
            let gapMax = CGFloat(210) // max encouraged follow distance
            let gapMin = CGFloat(200) // min encouraged follow
            let speedupMod = CGFloat(1.1)// increase by this when behind
            let releashingMod = CGFloat(1.5)
            let slowdownMod = CGFloat(0.9) // decrease by this when ahead
            //TODO slow down turnspeed and increase movespeed during mining boost
            
            if let piece = targetPiece{
                let distToNext = getGapSize(nextPiece: piece)
                if distToNext < gapMin{
                    deltaMod = deltaMod * slowdownMod
                } else if releashingFrames != 0 {
                    deltaMod = deltaMod * releashingMod
                    turnMod = 240
                } else if boosted && distToNext > gapMin {
                    deltaMod = deltaMod * 1.2 //TODO make this a var
                    turnMod = 300
                } else if distToNext > gapMax{
                    deltaMod = deltaMod * speedupMod
                    turnMod = 180
                }
            }
            
            if circle {
                targetAngle = sprite.zRotation - CGFloat(Double.pi / 8)
                turn(by: delta * 10)
                deltaMod *= 0.8
            }
            
            if !angleLocked {
                turn(by: delta * turnMod)
            }
            
            thruster.particleBirthRate = speed * 8
            super.moveForward(by: deltaMod)
        }
    }
    
    override func moveForward(by delta: CGFloat) {
        let translateVector = CGVector(dx: cos(angleCorrector()) * self.speed * delta, dy:  sin(angleCorrector()) * self.speed * delta)
        self.sprite.physicsBody?.applyForce(translateVector)
    }

    //TODO: Note that the angle at spawn is hardcoded.
    override func spawn(at spawnPoint: CGPoint) {
        sprite.size = CGSize(width: xRange.0 * sprite.size.width, height: yRange.0 * sprite.size.height)
        sprite.position = spawnPoint
        sprite.zRotation = targetAngle - CGFloat(Double.pi/2)
    }
    
    //Returns last in chain
    func getLastPiece() -> TruckPiece {
        var lastPiece: TruckPiece = self
        while let p = lastPiece.followingPiece {
            lastPiece = p
        }
        return lastPiece
    }
    
    //Returns first in chain
    func getFirstPiece() -> TruckPiece{
        var firstPiece: TruckPiece = self
        while let p = firstPiece.targetPiece {
            firstPiece = p
        }
        return firstPiece
    }
    
    //Attaches target piece into the chain
    func addToChain(adding piece: TruckPiece) {
        piece.targetPiece?.followingPiece = nil
        piece.targetPiece = getLastPiece()
        piece.followingPiece?.targetPiece = nil
        piece.followingPiece = nil
        getLastPiece().followingPiece = piece
        
        var followPiece: TruckPiece? = piece
        while let p = followPiece {
            p.lost = false
            p.releashingFrames = 240 //Note: Change this value to change the number of frames for releashing

            p.speed = self.speed
            p.boostSpeed = self.boostSpeed
            p.boosted = self.boosted
            p.normalSpeed = self.normalSpeed
            
            //TODO: make a function that clones attributes from a given truckpiece onto the
            
            p.sprite.name = self.sprite.name
            
            // rival to normal
            // if normal to rival
                        
            followPiece = p.followingPiece
         }
    }
    
    //NOTE: onImpact force unwraps sprite names, shouldn't be a problem though
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        //print("A",contact.bodyA.node?.name)
        //print("B",contact.bodyB.node?.name)
        let coeff: CGFloat = 10
//        let collisionVector = obj.lastVector.reflected(over: contact.contactNormal)
        let newNormal = reboundVector(from: contact.contactPoint).mult(by: coeff)
//        let newNormal = reboundVector(from: obj.sprite.position).mult(by: coeff)

        //Capsule vs Asteroid and Debris collision
        if obj.sprite.name == "asteroid" || obj.sprite.name == "debris" {
            self.addForce(vec: newNormal)
            durability -= obj.impactDamage
            print("OOF ouch! \(durability) hull remaining.")
            if !invincible && durability <= 0 {
                onDestroy()
            }
            
        //Capsule vs Lost Capsule collision
        } else if obj.sprite.name == "lost_capsule" {
            if self.sprite.name != "lost_capsule" || self.sprite === contact.bodyA { //This should ensure too lost capsules never connect to each other at the same time
                addToChain(adding: (obj as? TruckPiece)!)
            }
            
        //Capsule vs SpaceStation Collision
        } else if obj.sprite.name == "station_arm"{
            // contact w space station
            if obj.sprite.name == "station_arm" {
                // trigger entry
            } else {
                // bump
                print("bump")
            }
            
        //Capsule-Only Collisions
        } else if sprite.name == "capsule" {
            
            //Capsule vs Rival Capsule Collision
            if obj.sprite.name == "rival_capsule" {
                self.addForce(vec: newNormal)
                durability -= obj.impactDamage
                print("OOF ouch! \(durability) hull remaining.")
                if durability <= 0 {
                    onDestroy()
                }
            }
        
        //Rival-Only Collisions
        } else if sprite.name == "rival_capsule" {
            
            //Rival Capsule vs Capsule Collision
            if obj.sprite.name == "capsule" {
                self.addForce(vec: newNormal)
                durability -= obj.impactDamage
                print("OOF ouch! \(durability) hull remaining.")
                if durability <= 0 {
                    onDestroy()
                }
            }
        }
    }
        
    override func onDestroy() {
        //print("Truck should be destroyed but i didnt code this whoops my bad sorry team")
        //print("pop")
        //change name to destroyed_capsule?
        if !invincible && !destroyed{
            breakChain()
            self.followingPiece?.breakChain()
            dropItem(at: sprite.position)
            destroyed = true
            thruster.removeAllActions()
            thruster.removeFromParent()
            
            if let _ = thruster.parent {
                thruster.particleBirthRate = 0
                thruster.removeFromParent()
            }
            
            explode()
            
            let duration = Double.random(in: 0.7...1.0)
            let removeDate = Date().addingTimeInterval(duration)
            let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
        }

    }
    
    @objc func deleteSelf() {
        dropItem(at: self.sprite.position)
        for child in self.getChildren() {
            child?.removeFromParent()
        }
        
        if let _ = thruster.parent {
            thruster.particleBirthRate = 0
            thruster.removeFromParent()
        }
    }
    
    //Returns all attached pieces
    func getAllPieces() -> [TruckPiece] {
        var piece = getFirstPiece()
        var allPieces = [piece]
        while piece.followingPiece != nil{
            piece = piece.followingPiece!
            allPieces.append(piece)
        }
        return allPieces
    }
    
    //Returns sprite and thruster
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [thruster]
    }
    
    //Returns getChildren of all attached pieces
    func getAllChainedChildren() -> [SKNode?] {
        var nodes: [SKNode?] = []
        for piece in getAllPieces() {
            nodes += piece.getChildren()
        }
        return nodes
    }
    
    //Seperates from targetPiece, creates snap sprite, turns all pieces in chain into lost_capsules
    func breakChain(){
        if !isHead{
            let pos = self.targetPiece?.sprite.position
            self.targetPiece?.followingPiece = nil
            self.targetPiece = nil

            
            var followPiece: TruckPiece? = self
            while let p = followPiece {
                p.sprite.name = "lost_capsule"
                followPiece = p.followingPiece
                p.setBoost(b: false)
            }
        }
    }
    
    func dockPiece(){
        print("DockingChain")
        sprite.isHidden = true
        speed = 0
        docked = true
//        var piece: TruckPiece = getFirstPiece()
//        while let p = piece{
//            //p.
//
//        }
    }
    
    func undockPiece(){
        for piece in getAllPieces(){
            piece.sprite.isHidden = false
            piece.thruster.isHidden = false
            piece.speed = normalSpeed
            piece.docked = false
            piece.releashingFrames = 60
        }

    }
    func getGapSize(nextPiece: TruckPiece) -> CGFloat{
        let distancex = sprite.position.x - nextPiece.sprite.position.x
        let distancey = sprite.position.y - nextPiece.sprite.position.y
        let distance = sqrt(distancex * distancex + distancey * distancey)
        return distance
    }
}
