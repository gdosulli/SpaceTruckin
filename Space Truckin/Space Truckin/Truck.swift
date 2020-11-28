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
    let thruster: SKEmitterNode = SKEmitterNode(fileNamed: "sparkEmitter")!
    var distanceToHead: CGFloat = 0.0
    var targetPiece: TruckPiece?
    var followingPiece: TruckPiece?
    let mineDuration: TimeInterval = 5.0
    var lost = false
    var releashing = false
    var isHead = false
    var circle = false
    var invincible = false
    var maxLeashLength = CGFloat(250)
    
    convenience init(sprite s1: SKSpriteNode) {
        self.init(2, s1, nil, (1.3,1.0), (1.3,1.0), Inventory(), 100, 1, 0, 0)
    }
    
    convenience init(sprite s1: SKSpriteNode, target piece: TruckPiece) {
        self.init(2, s1, piece, (1.0,1.0), (1.0,1.0), Inventory(), piece.speed * 0.95, 1, 0, piece.boostSpeed)
        piece.followingPiece = self

    }
 
    convenience init(sprite s1: SKSpriteNode, durability: Int, size: CGFloat, speed: CGFloat, boostedSpeed: CGFloat) {

        self.init(durability, s1, nil, (size,size), (size,size), Inventory(), speed, 10, 0, boostedSpeed)
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
            if getGapSize(nextPiece: piece) > maxLeashLength && !releashing{
                //print("SNAP")
                breakChain()
            }
        }
        
        thruster.targetNode = sprite.parent
        thruster.position = sprite.position
        
        currentAngle = sprite.zRotation - 3.14/2
        thruster.emissionAngle = currentAngle

    }
    
    //Behavior for lost pieces
    func moveLost(by delta: CGFloat){
        // deltaMod adjusts the delta to 'accelerate' and 'decelerate' to maintain follow distance of trucks

        super.moveForward(by: delta * 0.4)
    }
    
    //TODO: Is this ever called?
    func setBoost(b: Bool) {
        boosted = b
        if b {
            speed = boostSpeed
            thruster.particleBirthRate = 5000
//            thruster.particleLifetime = 1.4
            thruster.particleScaleSpeed = -0.2
        } else {
            speed = normalSpeed
            thruster.particleBirthRate = 2000
//            thruster.particleLifetime = 0.6
            thruster.particleScaleSpeed = -0.4


        }
    }
    
    //TODO: Currently contains semi-hardcoded values for leashing truck pieces, some should become fields of Truck
    override func move(by delta: CGFloat) {
        if lost {
            moveLost(by: delta)
        } else {
            // deltaMod adjusts the delta to 'accelerate' and 'decelerate' to maintain follow distance of trucks
            let gapMax = CGFloat(130) // max encouraged follow distance
            let gapMin = CGFloat(125) // min encouraged follow
            let speedupMod = CGFloat(1.1)// increase by this when behind
            let releashingMod = CGFloat(1.5)
            let slowdownMod = CGFloat(0.9) // decrease by this when ahead
            //TODO slow down turnspeed and increase movespeed during mining boost
            var turnMod = CGFloat(60)
            var deltaMod = delta
            
            if let piece = targetPiece{
                let distToNext = getGapSize(nextPiece: piece)
                if distToNext < gapMin{
                    deltaMod = deltaMod * slowdownMod
                } else if releashing {
                    deltaMod = deltaMod * releashingMod
                    turnMod = 240
                } else if boosted && distToNext > gapMin {
                    deltaMod = deltaMod * 1.2 //TODO make this a var
                    turnMod = 120
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
            
            super.moveForward(by: deltaMod)
        }
    }
    
    override func moveForward(by delta: CGFloat) {
        let translateVector = CGVector(dx: cos(angleCorrector()) * self.speed * delta, dy:  sin(angleCorrector()) * self.speed * delta)
        self.sprite.physicsBody?.applyForce(translateVector)
    }
    
    // mining may end up as something that happens as long as a button is being held down (and there's enough energy) meaning the timeInterval aspect may not be forever
    func mine(for duration: TimeInterval) {
        lockDirection(for: duration)
        boostSpeed(for: duration)
        sprite.physicsBody?.angularVelocity = 0
        
        //set to not clash with other releashings ??
//        releashing = true
//        let date = Date().addingTimeInterval(3.0) //releashing timer
//        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(endReleashing), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
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
        piece.lost = false
        //if let remainingChain = piece.followingPiece {
        //    piece.followingPiece?.breakChain()
        //}
        
        piece.targetPiece?.followingPiece = nil
        piece.targetPiece = getLastPiece()
        piece.followingPiece?.targetPiece = nil
        piece.followingPiece = nil
        getLastPiece().followingPiece = piece
        
        var followPiece: TruckPiece? = piece
        while let p = followPiece {
            p.releashing = true
            print("reattaching\(String(describing: p.sprite.name))")
            p.collisionCategory = self.collisionCategory
            p.testCategory = self.testCategory
            p.sprite.physicsBody?.categoryBitMask = self.collisionCategory
            p.sprite.physicsBody?.contactTestBitMask = self.testCategory
            p.speed = self.speed
            p.boostSpeed = self.boostSpeed
            p.boosted = self.boosted
            p.normalSpeed = self.normalSpeed
            
            //TODO: make a function that clones attributes from a given truckpiece onto the
            
            p.sprite.name = self.sprite.name
            
            // rival to normal
            // if normal to rival
                        
            followPiece = p.followingPiece
            let date = Date().addingTimeInterval(3.0) //releashing timer
            let timer = Timer(fireAt: date, interval: 0, target: p, selector: #selector(endReleashing), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
         }
    }
    
    //Releashing should work by setting a timestamp for the releashing to be ended at, this would avoid releashings conflicting
    @objc func endReleashing() {
        releashing = false
        //print("Releashing ended")
    }
    
    //NOTE: onImpact force unwraps sprite names, shouldn't be a problem though
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        //print("A",contact.bodyA.node?.name)
        //print("B",contact.bodyB.node?.name)
        var collisionVector = contact.contactNormal
//        if self.sprite === contact.bodyB.node{
//            print("FLIP CAPSULE")
//            collisionVector.dx *= -1
//            collisionVector.dy *= -1
//        }
        //print(obj.sprite.name)
        //print("Vector:",collisionVector)
        
        //Capsule vs Asteroid and Debris collision
        if obj.sprite.name == "asteroid" || obj.sprite.name == "debris" {
            let newNormal = CGVector(dx: -10 * collisionVector.dx, dy: -10 * collisionVector.dy)
            self.addForce(vec: newNormal)
            durability -= obj.impactDamage
            print("OOF ouch! \(durability) hull remaining.")
            if durability <= 0 {
                onDestroy()
            }
            
            
        //Capsule vs Lost Capsule collision
        } else if obj.sprite.name == "lost_capsule" {
            if self.sprite.name != "lost_capsule" || self.sprite != contact.bodyA { //This should ensure too lost capsules never connect to each other at the same time
                addToChain(adding: (obj as? TruckPiece)!)
            }
            
        //Capsule vs SpaceStation Collision
        } else if obj.sprite.name == "station_arm"{
            // contact w space station
            if obj.sprite.name == "station_arm" {
                // trigger entry
                print("trigger entry w normal \(contact.contactNormal) at point \(contact.contactPoint)")
            } else {
                // bump
                print("bump")
            }
            
            
        //Capsule vs Rival Capsule collision
        } else if obj.sprite.name == "rival_capsule"{
            var newNormal = CGVector(dx: -10 * collisionVector.dx, dy: -10 * collisionVector.dy)
            self.addForce(vec: newNormal)
            //durability -= obj.impactDamage
            //print("OOF ouch! \(durability) hull remaining.")
            //if durability <= 0 {
            //    onDestroy()
            //}
        }
    }
        
    override func onDestroy() {
        //print("Truck should be destroyed but i didnt code this whoops my bad sorry team")
        print("pop")
        //change name to destroyed_capsule?
        breakChain()
        self.followingPiece?.breakChain()
        
        if !invincible {
            dropItem(at: sprite.position)
            destroyed = true
            explode()
        }
//        let duration = Double.random(in: 0.4...0.7)
//        let removeDate = Date().addingTimeInterval(duration)
//        let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
//        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func deleteSelf() {
        dropItem(at: self.sprite.position)
        self.sprite.removeFromParent()
        self.thruster.removeFromParent()
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
        let pos = self.targetPiece?.sprite.position
        self.targetPiece?.followingPiece = nil
        self.targetPiece = nil
        
        self.lost = true
        let snap = EffectBubble(type: .SNAP, duration: 0.5)
        self.sprite.parent?.addChild(snap.getChildren()[0]!)
        if let p = pos {
            snap.spawn(at: p)
        }
        
        var followPiece: TruckPiece? = self
        while let p = followPiece {
            p.collisionCategory = CollisionCategories.LOST_CAPSULE_CATEGORY
            p.testCategory = CollisionCategories.ASTEROID_CATEGORY
            p.sprite.name = "lost_capsule"
            p.sprite.physicsBody?.categoryBitMask = p.collisionCategory
            p.sprite.physicsBody?.contactTestBitMask = p.testCategory
            followPiece = p.followingPiece
            p.setBoost(b: false)
        }
    }
    
    func getGapSize(nextPiece: TruckPiece) -> CGFloat{
        let distancex = sprite.position.x - nextPiece.sprite.position.x
        let distancey = sprite.position.y - nextPiece.sprite.position.y
        let distance = sqrt(distancex * distancex + distancey * distancey)
        return distance
    }
}


// TODO: implement barrel-roll/dash/burst on swipe
//=====================================================================
//class TruckChain {
//    let head: TruckPiece!
//    var tail: TruckPiece!
//    var truckPieces: [TruckPiece]
//    var offset: CGFloat
//    var speedDecrement: CGFloat
//    var minimumSpeed: CGFloat
//    var greatDistance: Bool = false
//    var warningDistance: CGFloat
//    var boostRadius: CGFloat
//    var dashSpeed: CGFloat
//    var dashTimer: Timer?
//    var dashIndex = 0
//    var dashAngle: CGFloat = 0
//    var maxLeashLength: CGFloat = 250
//    var destroyedIndices = [Int]()
//    var destroyedPieces = [TruckPiece]()
//
//    init(head h: TruckPiece) {
//        head = h
//        head.isHead = true
//        head.invincible = true
//        tail = head
//        truckPieces = []
//        offset = head.sprite.size.height
//        speedDecrement = 0
//        minimumSpeed = 10
//        warningDistance = head.sprite.size.width * 3
//        boostRadius = head.sprite.size.width * 1.5
//        dashSpeed = 5
//    }
//
//    func getAllPieces() -> [TruckPiece] {
//        return [head] + truckPieces
//    }
//
//    func getLastPiece() -> TruckPiece {
//        var lastPiece: TruckPiece = head
//        while let p = lastPiece.followingPiece {
//            lastPiece = p
//        }
//        return lastPiece
//    }
//
//    func movePieces(by delta: CGFloat) {
//        //head.move(by: delta)
//        for piece in truckPieces {
//            piece.move(by: delta)
//        }
//    }
//
//    func getSprites() -> [SKSpriteNode] {
//        var sprites = [head.sprite!]
//        for piece in truckPieces {
//            sprites.append(piece.sprite!)
//        }
//        return sprites
//    }
//
//    func getThrusters() -> [SKEmitterNode] {
//        var thrusters : [SKEmitterNode] = []
//        let t1 = head.thruster
//        thrusters.append(t1)
//
//        for piece in truckPieces {
//            let t2 = piece.thruster
//            thrusters.append(t2)
//        }
//        return thrusters
//    }
//
//    func updateFollowers() {
//        head.update(by: 0)
//        for p in truckPieces {
//            p.update(by: 0)
//            if let target = p.targetPiece{
//                if p.getGapSize(nextPiece: target) > maxLeashLength && !p.releashing{
//                    //print("SNAP")
//                    breakChain(at: p)
//                }
//            }
//        }
//    }
//
//    func breakChain(at piece: TruckPiece){
//        let pos = piece.targetPiece?.sprite.position
//        piece.targetPiece?.followingPiece = nil
//        piece.targetPiece = nil
//        piece.lost = true
//        let snap = EffectBubble(type: .SNAP, duration: 0.5)
//        piece.sprite.parent?.addChild(snap.getChildren()[0]!)
//        if let p = pos {
//            snap.spawn(at: p)
//        }
//
//        var followPiece: TruckPiece? = piece
//        while let p = followPiece {
//            p.collisionCategory = CollisionCategories.LOST_CAPSULE_CATEGORY
//            p.testCategory = CollisionCategories.ASTEROID_CATEGORY
//            p.sprite.physicsBody?.categoryBitMask = p.collisionCategory
//            p.sprite.physicsBody?.contactTestBitMask = p.testCategory
//            followPiece = p.followingPiece
//        }
//    }
//
//    func updateDistance() {
//        if getMaxDistance() > warningDistance {
//            self.greatDistance = true
//        } else {
//            self.greatDistance = false
//        }
//    }
//
// TODO delay deletion so explosion play (i know how to do this)
//    func checkForDestroyed() {
//        if head.destroyed {
//            // game over
//        }
//
//        for i in 0..<truckPieces.count {
//            if truckPieces[i].destroyed {
//                destroyedIndices.append(i)
//            }
//        }
//
//        for i in destroyedIndices.reversed() {
//            let piece = truckPieces[i]
//            breakChain(at: piece)
//            for child in piece.getChildren() {
//                child?.removeFromParent()
//            }
//            truckPieces.remove(at: i)
//        }
//
//        destroyedIndices.removeAll()
//    }
//
//
//    func getMaxDistance() -> CGFloat {
//        var maxDistance: CGFloat = 0.0
//
//        for i in 0..<truckPieces.count {
//            if i == 0 {
//                let distance = head.sprite.position.distance(point: truckPieces[i].sprite.position)
//                if maxDistance < distance {
//                    maxDistance = distance
//                }
//            } else {
//                let distance = truckPieces[i].sprite.position.distance(point: truckPieces[i-1].sprite.position)
//                if maxDistance < distance {
//                    maxDistance = distance
//                }
//            }
//        }
//
//        return maxDistance
//    }
//
//    func mine(for duration: TimeInterval) {
//        head.mine(for: duration)
//        for p in truckPieces {
//            if p.collisionCategory == CollisionCategories.TRUCK_CATEGORY {
//                p.boostSpeed(for: duration)
//            }
//        }
//    }
//
//    func dash(angle: CGFloat) {
//        guard dashTimer == nil else { return }
//
//        print("dash at \(angle)")
//        dashAngle = angle
//        dashTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(pieceDash), userInfo: nil, repeats: true)
//    }
//
//    @objc func pieceDash() {
//        guard dashTimer != nil else { return }
//
//        // DASH
//
//    }
//
//    func add(piece: TruckPiece) {
//
//        var lastPiece: TruckPiece
//        var lastPos: CGPoint
//        var lastAngle: CGFloat
//
//        if truckPieces.count > 0 {
//            lastPiece = truckPieces[truckPieces.count-1]
//        } else {
//            lastPiece = head
//        }
//
//        lastPos = lastPiece.sprite.position
//        lastAngle = lastPiece.targetAngle
//
//
//        // move piece to a point behind the piece in front of it by offset amount
//        let newPos = CGPoint(x: lastPos.x - (cos(lastAngle) * offset), y: lastPos.y - (sin(lastAngle) * offset))
//
//
//        piece.sprite.zPosition = lastPiece.sprite.zPosition-1
//        piece.sprite.position = newPos
//        piece.changeTargetAngle(to: lastAngle)
//        piece.changeSpeed(to: lastPiece.speed-speedDecrement)
//
//        truckPieces.append(piece)
//    }
//
//    func getChildren() -> [SKNode?] {
//        var nodes = head.getChildren()
//        for piece in truckPieces {
//            nodes += piece.getChildren()
//        }
//
//        return nodes
//    }
//
//}
