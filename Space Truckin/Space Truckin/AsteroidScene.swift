//
//  AsteroidScene.swift
//  Space Truckin
//
//  Created on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

class AsteroidScene: SKScene {
    var head: SKSpriteNode!
    
    var asteroidsInScene : [Asteroid] = []
    
    // array for randomaly choosing an asteroid to load
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    
    var asteroidTimer : Timer!
    let truckCategory : UInt32 = 0x1 << 0
    
    
    override func didMove(to view: SKView) {
        print("In asteroid scene")
        // get rid of gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        // timer for asteroids
        asteroidTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(spawnAsteroid),
                                             userInfo: nil,
                                             repeats: true)
    }
    
    @objc func spawnAsteroid() {
        // randomly select asteroid to load
        let asteroid = SKSpriteNode(imageNamed:asteroids[Int.random(in: 0..<asteroids.count)])
        
        let spawnPoint = getRandPos(for: asteroid)
        
        let speed = CGFloat.random(in: 1...3)
        let targetAngle = CGFloat.random(in: 0...2 * CGFloat.pi)
        let rotation = Bool.random() ? -2 * CGFloat.pi : 2 * CGFloat.pi
        
        self.addChild(asteroid)
        
        
        let ast = Asteroid(1,
                           asteroid,
                           (30, 60),
                           (30, 60),
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
            y = self.frame.size.height / 2 + object.size.height
            y = Bool.random() ? y * -1 : y
        } else {
            // get random y coordinate
            let distr = GKRandomDistribution(lowestValue: Int(-self.frame.height / 2),
                                             highestValue: Int(self.frame.height / 2))
            y = CGFloat(distr.nextInt())
            
            // select left/right for x
            x = self.frame.size.width / 2 + object.size.width
            x = Bool.random() ? x * -1 : x
        }
        
        return CGPoint(x: x, y: y)
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
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
    }
}
