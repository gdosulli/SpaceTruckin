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


// IDEA FOR MINING: collision with an asteroid in general should do damage to a piece of the truck, but
// There should be a UI button ("MINE") that, when hit, transforms the head of the truck into a big drill
// and contact between an asteroid and the drill should damge/destroy the asteroid and give materials to
// the player.


class TruckPiece {
    var targetAngle: CGFloat
    
    var speed: CGFloat
    var rotationalSpeed: CGFloat
    let sprite: SKSpriteNode!
    let thruster: SKEmitterNode?
    var highlighted = false
    
    init(sprite s1: SKSpriteNode) {
        sprite = s1
        //sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        speed = 100
        rotationalSpeed = 0.25
        targetAngle = 3.14/2
        thruster = SKEmitterNode(fileNamed: "sparkEmitter")
        thruster?.zPosition = sprite.zPosition - 1
        thruster?.position = sprite.position
    
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
    }
    
    mutating func add(piece: TruckPiece) {
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
        

        piece.sprite.zPosition = lastPiece.sprite.zPosition-1
        piece.sprite.position = newPos
        piece.changeTargetAngle(to: lastAngle)
        piece.changeSpeed(to: lastPiece.speed-speedDecrement)
        if piece.speed < minimumSpeed {
            piece.changeSpeed(to: minimumSpeed)
        }
        
        let roation = SKAction.rotate(toAngle: piece.targetAngle, duration: TimeInterval(piece.rotationalSpeed), shortestUnitArc: true)
        piece.sprite.run(roation)
        
        truckPieces.append(piece)
    }

}
extension TruckChain {
    init(head h: TruckPiece) {
        head = h
        truckPieces = []
        offset = head.sprite.size.height
        speedDecrement = 10
        minimumSpeed = 20
    }
}


class TruckScene: SKScene, SKPhysicsContactDelegate {
    var head: TruckPiece!
    var chain: TruckChain!
    
    var lastTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        // get rid of gravity
       self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
       self.physicsWorld.contactDelegate = self
       
        
        
        let sprite = SKSpriteNode(imageNamed: "space_truck_cab")
        head = TruckPiece(sprite: sprite)
        head.sprite.zPosition = 10

        chain = TruckChain(head: head)

        
        chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))

        
        for piece in chain.getSprites() {
            self.addChild(piece)
        }
        
        for thruster in chain.getThrusters() {
            self.addChild(thruster)
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        // calculate target angle
        head.changeAngleTo(point: pos)
        head.highlighted = true
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        head.changeAngleTo(point: pos)
    }
    
    func touchUp(atPoint pos : CGPoint) {
        head.highlighted = false
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
            chain.movePieces(by: delta)

        } else {
            let delta : CGFloat = 0
            //chain.movePieces(by: delta)
            chain.movePieces(by: delta)


        }
        chain.updateFollowers()
        lastTime = currentTime
        
    }
}
