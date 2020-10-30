//
//  Movable.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import CoreGraphics
import SpriteKit

class Movable {
    var speed: CGFloat
    var rotation: CGFloat
    var targetAngle: CGFloat
    var sprite: SKSpriteNode!
    
    init(speed: CGFloat, rotation: CGFloat, angleInRadians: CGFloat, sprite: SKSpriteNode) {
        self.speed = speed;
        self.rotation = rotation
        self.targetAngle = angleInRadians
        self.sprite = sprite
    }

    func translate(by vector: CGPoint) {
       sprite.position.x += vector.x
       sprite.position.y += vector.y
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
        let translateVector = CGPoint(x: cos(targetAngle) * self.speed * delta, y:  sin(targetAngle) * self.speed * delta)
        self.translate(by: translateVector)
    }
    
}
