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
    
    // array for randomaly choosing an asteroid to load
    // TODO: modify to actual asteroids
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    var asteroidTimer : Timer!
    
    // setup physics detection
    let asteroidCategory : UInt32 = 0x1 << 1
    let truckCategory : UInt32 = 0x1 << 0
    
    
    override func didMove(to view: SKView) {
        print("In game scene")
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
        
        // set random asteroid size
        let dimension = Int.random(in: 30...60)
        asteroid.size = CGSize(width: dimension, height: dimension)
        
        // add physics and collision detection to asteroid
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = truckCategory
        asteroid.physicsBody?.collisionBitMask = 0
        
        self.addChild(asteroid)
        
        // set random initial position
        let (initX, initY) = getRandPos(for: asteroid)
        asteroid.position = CGPoint(x: initX, y: initY)
        
        // get random speed and direction for asteroid to travel across screen
        let duration : TimeInterval = Double.random(in: 8...16)
        var action  = [SKAction]()
        let (endX, endY) = getRandPos(for: asteroid)
        action.append(SKAction.move(to: CGPoint(x: endX, y: endY), duration: duration))
        
        // set rotation for asteroid
        let speed = Double.random(in: 3...8) as TimeInterval
        let rotation = Bool.random() ? -2 * CGFloat.pi : 2 * CGFloat.pi
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: rotation, duration: speed))
        asteroid.run(rotateAction)
        
        // remove object after it has exited the screen
        action.append(SKAction.removeFromParent())
        
        // run action
        asteroid.run(SKAction.sequence(action))
    }
    
    // function returns random offscreen position for space object projectile
    func getRandPos(for object: SKSpriteNode) -> (x: CGFloat, y: CGFloat) {
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
        
        return (x, y)
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
