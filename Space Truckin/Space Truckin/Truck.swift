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

class TruckPiece: SpaceObject {
    let thruster: SKEmitterNode?
    var distanceToHead: CGFloat = 0.0
    var targetPiece: TruckPiece?
    
    init(sprite s1: SKSpriteNode) {
        thruster = SKEmitterNode(fileNamed: "sparkEmitter")

        super.init(2, s1, (1.0,1.0), (1.0,1.0), Inventory(100,0), 100, 1, 0)
        
        thruster?.zPosition = sprite.zPosition - 2
        thruster?.position = sprite.position
    }
    
    init(sprite s1: SKSpriteNode, target piece: TruckPiece) {
        thruster = SKEmitterNode(fileNamed: "sparkEmitter")

        targetPiece = piece
        
        super.init(2, s1, (1.0,1.0), (1.0,1.0), Inventory(100,0), 100, 1, 0)

        thruster?.zPosition = sprite.zPosition - 2
        thruster?.position = sprite.position
    }
 
    init(sprite s1: SKSpriteNode, durability: Int, size: CGFloat, speed: CGFloat) {
        thruster = SKEmitterNode(fileNamed: "sparkEmitter")

        super.init(durability, s1, (size,size), (size,size), Inventory(100,0), speed, 0.5, 0)
    }
    
    override func translate(by vector: CGPoint) {
        super.translate(by: vector)
        
        thruster?.position = sprite.position
        thruster?.zRotation = sprite.zRotation
    }
    
    override func update() {
        if let piece = targetPiece {
            changeAngleTo(point: piece.sprite.position)
        }
    }
    
    override func move(by delta: CGFloat) {
        // set the rotation here
        // Truck could have a rotation speed, and set an animation to rotate it the correct angle
        // at the correct speed. getting new input would interrupt the old animation
        // targetAngle needs to be changed so that the nose of the truck is the front
        let roation = SKAction.rotate(toAngle: targetAngle - (3.14/2), duration: TimeInterval(self.rotation), shortestUnitArc: true)
        sprite.run(roation)
        // the problem with this code is that it doesn't bother rotating to an angle below the center line
        // some flaw in targetAngle?

        super.move(by: delta)
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        
    }
    
    override func onDestroy() {
        
    }
    
    override func getChildren() -> [SKNode?] {
        return super.getChildren() + [thruster]
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
        speedDecrement = 5
        minimumSpeed = 10
        warningDistance = head.sprite.size.width * 3
        boostRadius = head.sprite.size.width * 1.5
        dashSpeed = 5
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
        if let t = head.thruster {
            thrusters.append(t)
        }
        for piece in truckPieces {
            if let t2 = piece.thruster {
                thrusters.append(t2)
            }
        }
        
        return thrusters
    }
    
    func updateFollowers() {
        for i in 0..<truckPieces.count {
            if i == 0 {
                truckPieces[i].changeAngleTo(point: head.sprite.position)
            } else {
                truckPieces[i].changeAngleTo(point: truckPieces[i-1].sprite.position)
            }
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
