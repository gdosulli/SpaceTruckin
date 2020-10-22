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

class TruckPiece {
    var targetAngle: CGFloat
    
    var baseSpeed: CGFloat
    var speed: CGFloat
    var rotationalSpeed: CGFloat
    let sprite: SKSpriteNode!
    let thruster: SKEmitterNode?
    var highlighted = false
    var boosted = false
    var distanceToHead: CGFloat = 0.0
    
    init(sprite s1: SKSpriteNode) {
        sprite = s1
        baseSpeed = 100
        speed = baseSpeed
        rotationalSpeed = 0.25
        targetAngle = 3.14/2
        thruster = SKEmitterNode(fileNamed: "sparkEmitter")
        thruster?.zPosition = sprite.zPosition - 1
        thruster?.position = sprite.position
    
    }
    
    func boostSpeed(to newSpeed: CGFloat, for time: TimeInterval) {
        speed = newSpeed
        SKAction.run {
            SKAction.wait(forDuration: time)
            self.speed = self.baseSpeed
        }
    }
    
    func translate(by vector: CGPoint) {
        sprite.position.x += vector.x
        sprite.position.y += vector.y
        
        thruster?.position = sprite.position
        thruster?.zRotation = sprite.zRotation
    }
    
    func changeAngleTo(point pos: CGPoint) {
        let difference = CGPoint(x: pos.x - sprite.position.x, y: pos.y - sprite.position.y)
        let diffMag = sqrt(difference.x * difference.x + difference.y * difference.y)
        let unitVec = CGPoint(x: difference.x / diffMag, y: difference.y / diffMag)
        let sine = atan2(unitVec.y, unitVec.x)
        changeTargetAngle(to: sine)
    }
    
    func changeTargetAngle(to angle: CGFloat) {
        targetAngle = angle
    }
    
    func changeTargetAngle(by angle: CGFloat) {
        targetAngle = angle
    }
    
    func changeSpeed(to: CGFloat) {
        speed = to
    }
    
    func changeSpeed(by: CGFloat) {
        speed += by
    }
    
    func move(by delta: CGFloat) {
        // set the rotation here
        // Truck could have a rotation speed, and set an animation to rotate it the correct angle
        // at the correct speed. getting new input would interrupt the old animation
        // targetAngle needs to be changed so that the nose of the truck is the front
        let roation = SKAction.rotate(toAngle: targetAngle - (3.14/2), duration: TimeInterval(rotationalSpeed), shortestUnitArc: true)
        sprite.run(roation)
        // the problem with this code is that it doesn't bother rotating to an angle below the center line
        // some flaw in targetAngle?
    
        // do the translation here
        let translateVector = CGPoint(x: cos(targetAngle) * self.speed * delta, y:  sin(targetAngle) * self.speed * delta)
        self.translate(by: translateVector)
        

    }
}



struct TruckChain {
    let head: TruckPiece!
    var truckPieces: [TruckPiece]
    var offset: CGFloat
    var speedDecrement: CGFloat
    var minimumSpeed: CGFloat
    var greatDistance: Bool = false
    var warningDistance: CGFloat
    var boostRadius: CGFloat

    func movePieces(by delta: CGFloat) {
        head.move(by: delta)
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
    
    func updateHeadDistance() {
        for piece in truckPieces {
            piece.distanceToHead = piece.sprite.position.distance(point: head.sprite.position)
            if !piece.boosted && piece.distanceToHead < boostRadius {
                print("boosted")
                piece.boostSpeed(to: head.speed-1, for: 10.0)
            }
        }
    }
    
    mutating func updateDistance() {
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
}
