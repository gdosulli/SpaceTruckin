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
    var boostSpeed: CGFloat
    var normalSpeed: CGFloat
    var outsideForces: CGVector
    var boosted = false
    
    
    init(speed: CGFloat, rotation: CGFloat, angleInRadians: CGFloat, sprite: SKSpriteNode, boostSpeed: CGFloat) {
        self.speed = speed
        self.rotation = rotation
        self.targetAngle = angleInRadians
        self.sprite = sprite
        self.currentAngle = 3.14/2
        self.normalSpeed = speed
        self.boostSpeed = boostSpeed
        self.outsideForces = CGVector(dx: 0, dy: 0)
    }

    func translate(by vector: CGPoint) {
        sprite.position.x += vector.x + outsideForces.dx
        sprite.position.y += vector.y + outsideForces.dy
        outsideForces.dx *= 0.9
        outsideForces.dy *= 0.9
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
           targetAngle += angle
    }
       
    func changeSpeed(to: CGFloat) {
           speed = to
    }
       
    func changeSpeed(by: CGFloat) {
           speed += by
    }
    
    func addForce(vec: CGVector) {
        let x = outsideForces.dx + vec.dx
        let y = outsideForces.dy + vec.dy
        
        outsideForces = CGVector(dx: x, dy: y)
    }
       
    func move(by delta: CGFloat) {
        let translateVector = CGPoint(x: cos(targetAngle) * self.speed * delta, y:  sin(targetAngle) * self.speed * delta)
        self.translate(by: translateVector)
    }
    
    func moveForward(by delta: CGFloat) {
        // moves forward instead of in the direction of the target angle
        let translateVector = CGPoint(x: cos(angleCorrector()) * self.speed * delta, y:  sin(angleCorrector()) * self.speed * delta)
        self.translate(by: translateVector)
    }
    
    
    // Adjusts angular velocity of truckpiece depending on angle to target
    func turn(by delta: CGFloat) {
        // TODO: POSSIBLY REIMPLEMENT DELTA INTO THIS / or limit turn speed if needed
        var angleDifference = (targetAngle - angleCorrector())
        if (angleDifference > CGFloat(Double.pi)) {
            angleDifference -= CGFloat(Double.pi*2)
        } else if (angleDifference) < CGFloat(-Double.pi){
            angleDifference += CGFloat(Double.pi*2)
        }
        sprite.physicsBody?.angularVelocity = angleDifference * delta
    }
    
    func lockDirection(for interval: TimeInterval) {
        angleLocked = true
        let date = Date().addingTimeInterval(interval)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(unlock), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func boostSpeed(for duration: TimeInterval) {
        speed = boostSpeed
        let date = Date().addingTimeInterval(duration)
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(revertSpeed), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    func angleCorrector() -> CGFloat { return (sprite.zRotation + CGFloat(Double.pi/2)) }
    
    @objc func unlock() {
        angleLocked = false
    }
    
    @objc func revertSpeed() {
        speed = normalSpeed
    }
    
}


// TODO: Implement a lockDirection(for interval: TimeInterval) that makes it so a Movable can't rotate for
// a specified time


// Also TODO: make it so ships can only move forwards, and rotate towards a targetPoint over time

