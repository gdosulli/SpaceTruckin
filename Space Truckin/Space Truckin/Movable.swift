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
    var currentAngle: CGFloat
    var targetAngle: CGFloat
    var sprite: SKSpriteNode!
    var angleLocked = false
    
    init(speed: CGFloat, rotation: CGFloat, angleInRadians: CGFloat, sprite: SKSpriteNode) {
        self.speed = speed;
        self.rotation = rotation
        self.targetAngle = angleInRadians
        self.sprite = sprite
        self.currentAngle = 3.14/2
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
    
    func moveForward(by delta: CGFloat) {
        let translateVector = CGPoint(x: cos(currentAngle) * self.speed * delta, y:  sin(currentAngle) * self.speed * delta)
        self.translate(by: translateVector)
    }
    
    func turn(by delta: CGFloat) {
        let rotate = SKAction.rotate(toAngle: currentAngle + (targetAngle * delta * rotation), duration: TimeInterval(delta), shortestUnitArc: true)
        sprite.run(rotate)
    }
    
    func lockDirection(for interval: TimeInterval) {
        angleLocked = true
        let date = Date().addingTimeInterval(interval)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(unlock), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func unlock() {
        angleLocked = false
    }
    
}


// TODO: Implement a lockDirection(for interval: TimeInterval) that makes it so a Movable can't rotate for
// a specified time


// Also TODO: make it so ships can only move forwards, and rotate towards a targetPoint over time

