//
//  GameScene.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Player {
    var head: TruckPiece
    var chain: TruckChain
    let cam = SKCameraNode()
    
    func getChildren() -> [SKNode?] {
        return chain.getChildren()
    }
    
    func update(by delta: CGFloat) {
        head.move(by: delta)
        chain.movePieces(by: delta)
        chain.updateFollowers()
    }
}
extension Player {
    init(_ head: TruckPiece) {
        self.head = head
        self.chain = TruckChain(head: head)
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    
    let cam = SKCameraNode()
    let scaleBounds = CGPoint(x: 2, y: 5)
    var camScale: CGFloat = 3
        
    var lastTime: TimeInterval?
    
    var showOffScreenPieces = false
    
    var background: SKSpriteNode?


    override func didMove(to view: SKView) {
        // get rid of gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        self.camera = cam
        let sprite = SKSpriteNode(imageNamed: "space_truck_cab")
        player = Player(TruckPiece(sprite: sprite, durability: 2, size: 1, speed: 100 ))
        player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2")))
        player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        
        
        for c in player.getChildren() {
            self.addChild(c!)
        }
        
        
        background = SKSpriteNode(imageNamed: "spacebackground")
        background?.size = CGSize(width: self.frame.size.width * 32, height:  self.frame.size.height * 32)
        background?.position = CGPoint(x: frame.midX, y: frame.midY)
        background?.zPosition = -100
        background?.alpha = 0.6
        if let bg = background {
            self.addChild(bg)
        }
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        player.head.changeAngleTo(point: pos)

    }
    
    func touchMoved(toPoint pos : CGPoint) {
        player.head.changeAngleTo(point: pos)

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
        var delta: CGFloat
        if let t = lastTime {
            delta = CGFloat(currentTime - t)
        } else {
            delta = 0
        }
        
        lastTime = currentTime
        
        player.update(by: delta)
        updateCamera()
    }
    
    func updateCamera() {
        cam.xScale = camScale
        cam.yScale = camScale
        cam.position = player.head.sprite.position
        
    }
}
