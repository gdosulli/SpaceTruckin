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


struct CollisionCategories {
    static let TRUCK_CATEGORY = UInt32(0)
    static let ASTEROID_CATEGORY = UInt32(1.0)
    static let SPACE_JUNK_CATEGORY = UInt32(2.0)
}



class TruckPiece: SpaceObject {
    let thruster: SKEmitterNode = SKEmitterNode(fileNamed: "sparkEmitter")!
    var distanceToHead: CGFloat = 0.0
    var targetPiece: TruckPiece?
    let mineDuration: TimeInterval = 5.0
    
    convenience init(sprite s1: SKSpriteNode) {
        self.init(2, s1, nil, (1.0,1.0), (1.0,1.0), Inventory(), 100, 1, 0, CollisionCategories.TRUCK_CATEGORY, CollisionCategories.ASTEROID_CATEGORY, 0)
    }
    
    convenience init(sprite s1: SKSpriteNode, target piece: TruckPiece) {
        self.init(2, s1, piece, (1.0,1.0), (1.0,1.0), Inventory(), piece.speed * 0.95, 1, 0, CollisionCategories.TRUCK_CATEGORY, CollisionCategories.ASTEROID_CATEGORY, piece.boostSpeed * 0.95)

    }
 
    convenience init(sprite s1: SKSpriteNode, durability: Int, size: CGFloat, speed: CGFloat, boostedSpeed: CGFloat) {

        self.init(durability, s1, nil, (size,size), (size,size), Inventory(), speed, 10, 0, CollisionCategories.TRUCK_CATEGORY, CollisionCategories.ASTEROID_CATEGORY, boostedSpeed)
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
    _ collisionCategory: UInt32,
    _ testCategory: UInt32,
    _ boostSpeed: CGFloat) {
        
        
        
        super.init(durability, sprite, xRange, yRange, inventory, speed, rotation, targetAngle, collisionCategory, testCategory, boostSpeed)
        
        self.targetPiece = targetPiece
        
        let margin: CGFloat = 0.8
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width * margin, height: margin * sprite.size.height))
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = self.collisionCategory
        sprite.physicsBody?.contactTestBitMask = self.testCategory
        sprite.physicsBody?.collisionBitMask = 0
        //sprite.physicsBody?.linearDamping = 1 // testing
        thruster.zPosition = sprite.zPosition - 2
        thruster.position = sprite.position
        //thruster.targetNode = //gamescene
    }
    
    
    override func translate(by vector: CGPoint) {
        super.translate(by: vector)
        
        thruster.position = sprite.position
        thruster.zRotation = sprite.zRotation
    }
    
    override func update() {
        if let piece = targetPiece {
            changeAngleTo(point: piece.sprite.position)
            //Chain breaking condition
            if getGapSize(nextPiece: piece) > 250{ //change value to change break range, TODO make this an external value
                self.targetPiece = nil
            }
        }

        currentAngle = sprite.zRotation - 3.14/2
    }
    
    //Currently contains semi-hardcoded values for leashing truck pieces
    override func move(by delta: CGFloat) {
        // deltaMod adjusts the delta to 'accelerate' and 'decelerate' to maintain follow distance of trucks
        let gapMax = CGFloat(130) // max encouraged follow distance
        let gapMin = CGFloat(125) // min encouraged follow
        let speedupMod = CGFloat(1.1) // increase by this when behind
        let slowdownMod = CGFloat(0.9) // decrease by this when ahead
        
        var turnMod = CGFloat(60)
        var deltaMod = delta
        
        if let piece = targetPiece{
            let distToNext = getGapSize(nextPiece: piece)
            if distToNext > gapMax{
                deltaMod = deltaMod * speedupMod
                turnMod = 180
            } else if distToNext < gapMin{
                deltaMod = deltaMod * slowdownMod
            }
        }
        
        if !angleLocked {
            turn(by: delta * turnMod)
        }
        
        super.moveForward(by: deltaMod)
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
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        
    }
    
    override func onDestroy() {
        
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [thruster]
    }
    
    func getGapSize(nextPiece: TruckPiece) -> CGFloat{
        let distancex = sprite.position.x - nextPiece.sprite.position.x
        let distancey = sprite.position.y - nextPiece.sprite.position.y
        let distance = sqrt(distancex * distancex + distancey * distancey)
        
        return distance
    }
}

// TODO: implement barrel-roll/dash/burst on swipe

class TruckChain {
    let head: TruckPiece!
    var truckPieces: [TruckPiece]
    var offset: CGFloat
    var speedDecrement: CGFloat
    var minimumSpeed: CGFloat
    var greatDistance: Bool = false
    var warningDistance: CGFloat
    var boostRadius: CGFloat
    var dashSpeed: CGFloat
    var dashTimer: Timer?
    var dashIndex = 0
    var dashAngle: CGFloat = 0

    init(head h: TruckPiece) {
        head = h
        truckPieces = []
        offset = head.sprite.size.height
        speedDecrement = 0
        minimumSpeed = 10
        warningDistance = head.sprite.size.width * 3
        boostRadius = head.sprite.size.width * 1.5
        dashSpeed = 5
    }
    
    func getLastPiece() -> TruckPiece {
        if truckPieces.count == 0 {
            return head
        }
        return truckPieces[truckPieces.count-1]
    }
    
    func movePieces(by delta: CGFloat) {
        //head.move(by: delta)
        for piece in truckPieces {
            piece.move(by: delta)
        }
    }

    func getSprites() -> [SKSpriteNode] {
        var sprites = [head.sprite!]
        for piece in truckPieces {
            sprites.append(piece.sprite!)
        }

        return sprites
    }
    
    func getThrusters() -> [SKEmitterNode] {
        var thrusters : [SKEmitterNode] = []
        let t1 = head.thruster
        thrusters.append(t1)
        
        for piece in truckPieces {
            let t2 = piece.thruster
            thrusters.append(t2)

        }
        
        return thrusters
    }
    
    func updateFollowers() {
        for p in truckPieces {
            p.update()
        }
        
        //updateHeadDistance()
        
    }
    
    func updateDistance() {
        if getMaxDistance() > warningDistance {
            self.greatDistance = true
        } else {
            self.greatDistance = false
        }
    }
    
    
    func getMaxDistance() -> CGFloat {
        var maxDistance: CGFloat = 0.0
        
        for i in 0..<truckPieces.count {
            if i == 0 {
                let distance = head.sprite.position.distance(point: truckPieces[i].sprite.position)
                if maxDistance < distance {
                    maxDistance = distance
                }
            } else {
                let distance = truckPieces[i].sprite.position.distance(point: truckPieces[i-1].sprite.position)
                if maxDistance < distance {
                    maxDistance = distance
                }
            }
        }
        
        return maxDistance
    }
    
    func mine(for duration: TimeInterval) {
        head.mine(for: duration)
        for p in truckPieces {
            p.boostSpeed(for: duration)
        }
    }
    
    func dash(angle: CGFloat) {
        guard dashTimer == nil else { return }
        
        print("dash at \(angle)")
        dashAngle = angle
        dashTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(pieceDash), userInfo: nil, repeats: true)
    }
    
    @objc func pieceDash() {
        guard dashTimer != nil else { return }

        // DASH
        
    }

    func add(piece: TruckPiece) {
        
        var lastPiece: TruckPiece
        var lastPos: CGPoint
        var lastAngle: CGFloat
        
        if truckPieces.count > 0 {
            lastPiece = truckPieces[truckPieces.count-1]
        } else {
            lastPiece = head
        }
        
        lastPos = lastPiece.sprite.position
        lastAngle = lastPiece.targetAngle
        
        
        // move piece to a point behind the piece in front of it by offset amount
        let newPos = CGPoint(x: lastPos.x - (cos(lastAngle) * offset), y: lastPos.y - (sin(lastAngle) * offset))
        

        print(lastPiece.speed)
        piece.sprite.zPosition = lastPiece.sprite.zPosition-1
        piece.sprite.position = newPos
        piece.changeTargetAngle(to: lastAngle)
        piece.changeSpeed(to: lastPiece.speed-speedDecrement)
        
        truckPieces.append(piece)
    }
    
    
    func getChildren() -> [SKNode?] {
        var nodes = head.getChildren()
        for piece in truckPieces {
            nodes += piece.getChildren()
        }
        
        return nodes
    }

}
