//
//  TruckScene.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//
import SpriteKit
import GameplayKit


// What if each capsule had an angle and a speed, not a target point.
// The capsule orients itself about the angle and moves "forward" by it's speed
// The head capsule could take its angle from where the player taps
// Each subsequent capsule could take its angle from the capsule before it
// That might make it snakelike


class TruckPiece {
    var targetAngle: CGFloat
    
    var speed: CGFloat
    let sprite: SKSpriteNode!
    var highlighted = false
    
    init(sprite s1: SKSpriteNode) {
        sprite = s1
        speed = 100
        targetAngle = 3.14 / 2
    
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
        // set the rotation here
        
        // something to do with the tangent (targetAngle.y, targetAngle.x)
        // do the translation here
        let translateVector = CGPoint(x: cos(targetAngle) * self.speed * delta, y:  sin(targetAngle) * self.speed * delta)
        self.translate(by: translateVector)
    }
}

//struct TruckChain {
//    let head: TruckPiece!
//    var truckPieces: [TruckPiece]
//
//    func movePieces(by delta: CGFloat) {
//        head.moveToTarget(by: delta)
//        for piece in truckPieces {
//            piece.moveToTarget(by: delta)
//        }
//    }
//
//    func getSprites() -> [SKSpriteNode] {
//        var sprites = [head.sprite!]
//        for piece in truckPieces {
//            sprites.append(piece.sprite!)
//        }
//
//        return sprites
//    }
//
//}
//extension TruckChain {
//    init(head h: TruckPiece) {
//        head = h
//        truckPieces = []
//    }
//}


class TruckScene: SKScene {
    var head: TruckPiece!
//    var chain: TruckChain!
    
    var lastTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        let sprite = SKSpriteNode(imageNamed: "space_truck_cab")
        // set pos and stuff
        print(sprite.position)
        head = TruckPiece(sprite: sprite)
        self.addChild(head.sprite)
//        chain = TruckChain(head: head)
//
//        for piece in chain.getSprites() {
//            self.addChild(piece)
//        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        // calculate target angle
        head.changeAngleTo(point: pos)
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        head.changeAngleTo(point: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let t = lastTime {
            let delta = CGFloat(currentTime - t)
            //chain.movePieces(by: delta)
            head.move(by: delta)

        } else {
            let delta : CGFloat = 0
            //chain.movePieces(by: delta)
            head.move(by: delta)


        }
        
        lastTime = currentTime
        
    }
}
