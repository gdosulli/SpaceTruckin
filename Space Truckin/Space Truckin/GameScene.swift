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
    
    var background: SKEmitterNode!
    
    var asteroidsInScene : [Asteroid] = []
    
    // array for randomaly choosing an asteroid to load
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    
    var asteroidTimer : Timer!


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
        
        
        background = SKEmitterNode(fileNamed: "StarryBackground")
        background.advanceSimulationTime(50)
        background.zPosition = -1
        self.addChild(background)
        
        // timer for asteroids
        asteroidTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(spawnAsteroid),
                                             userInfo: nil,
                                             repeats: true)
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
        for asteroid in asteroidsInScene {
            asteroid.move(by: delta)
        }
        
        updateCamera()
    }
    
    func updateCamera() {
        cam.xScale = camScale
        cam.yScale = camScale
        cam.position = player.head.sprite.position
        
    }
    
    @objc func spawnAsteroid() {
        // randomly select asteroid to load
        let asteroid = SKSpriteNode(imageNamed:asteroids[Int.random(in: 0..<asteroids.count)])
        
        let spawnPoint = getRandPos(for: asteroid)
        
        let speed = CGFloat.random(in: 50...150)
        let targetAngle = CGFloat.random(in: 0...2 * CGFloat.pi)
        let rotation = Bool.random() ? -2 * CGFloat.pi : 2 * CGFloat.pi
        
        self.addChild(asteroid)
        
        
        let ast = Asteroid(1,
                           asteroid,
                           (150, 350),
                           (150, 350),
                           Inventory(),
                           speed,
                           rotation,
                           targetAngle)
        
        ast.spawn(at: spawnPoint)
        
        // add asteroid to asteroids
        asteroidsInScene.append(ast)
    }
    
    // function returns random offscreen position for space object projectile
    func getRandPos(for object: SKSpriteNode) -> CGPoint {
        var x : CGFloat
        var y : CGFloat
        
        // pick x or y for object randomly
        let pickRandWidth = Bool.random()
        
        if pickRandWidth {
            // get random x coordinate
            let distr = GKRandomDistribution(lowestValue: Int(-self.frame.width / 2),
                                             highestValue: Int(self.frame.width / 2))
            x = CGFloat(distr.nextInt())
            
            // select top/bottom for y
            y = self.frame.size.height * 2 + object.size.height
            y = Bool.random() ? y * -1 : y
        } else {
            // get random y coordinate
            let distr = GKRandomDistribution(lowestValue: Int(-self.frame.height / 2),
                                             highestValue: Int(self.frame.height / 2))
            y = CGFloat(distr.nextInt())
            
            // select left/right for x
            x = self.frame.size.width * 2 + object.size.width
            x = Bool.random() ? x * -1 : x
        }
        
        return CGPoint(x: x, y: y)
    }
}
