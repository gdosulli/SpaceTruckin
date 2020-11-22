//
//  Area.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/20/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

struct SpawnRate {
    var obj: SpaceObject
    var rate: TimeInterval
}

class Area {
    var scene: AreaScene?
    
    var spawnRates: [SpawnRate]!
    var initialItems: [SpaceObject]?
    var uniqueItems: [SpaceObject]!

    var timers: [String: Timer] = [:]
    var gameIsPaused = false

    var landmark: SpaceObject?
    
    var backgroundItems = [SKNode]()
    
    var objectsInArea: [SKSpriteNode? : SpaceObject?] = [:]
    
    var destroyedNodes = [SKSpriteNode]()
    
        
    // player object
    var player: Player!
    
    
    // array for randomaly choosing an asteroid to load
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    var debris = ["satellite_1", "cell_tower1"]
    
    init(scene gameScene: AreaScene) {
        scene = gameScene
    }
    
    func loadArea() {
        // just in case this failed to happen on unload
        //scene?.removeAllChildren()
        // add background in
        for n in backgroundItems {
            scene?.addChild(n)
        }
        // spawn initial objects
        if let objs = initialItems {
            for o in objs {
                addObject(obj: o)
            }
        }
        
        // start spawn timers
        setTimer()
        
        // reintroduce player
        playerWarp()
    }
    
    @objc func spawnObject(timer: Timer) {
        guard let context = timer.userInfo as? [String: SpaceObject] else { return }
        let obj = context["obj"]?.copy()
        print(obj?.sprite.name)
        let spawnPoint = getRandPos(for: player.head, radius: 1000)
        let speed = CGFloat.random(in: 25...75)
        let targetAngle = CGFloat.random(in: 0...2 * CGFloat.pi)
        let rotation = Bool.random() ? -1 * CGFloat.pi : 1 * CGFloat.pi
        obj?.speed = speed
        obj?.targetAngle = targetAngle
        obj?.rotation = rotation
        obj?.spawn(at: spawnPoint)
//        obj?.sprite.size = CGSize(width: obj!.xRange.0, height: obj!.yRange.0)
//        obj?.sprite.position = spawnPoint
        addObject(obj: obj!)
        
        // object spawn code
    }
    
    // TODO: Overhaul this so it f*ckin works properly and doesn't spawn on the player
    func getRandPos(for object: SpaceObject, radius: CGFloat) -> CGPoint {
        let angle = Double.random(in: 0...(2*Double.pi))
        let x = object.sprite.position.x + CGFloat(cos(angle))*radius
        let y = object.sprite.position.y + CGFloat(sin(angle))*radius
        
        return CGPoint(x: x, y: y)
    }
    
//    func getRandPos(for object: SpaceObject) -> CGPoint {
//        var x : CGFloat
//        var y : CGFloat
//
//        // pick x or y for object randomly
//        let pickRandWidth = Bool.random()
//        let center = CGPoint(x: player.head.sprite.position.x,
//                             y: player.head.sprite.position.y)
//
//        if pickRandWidth {
//            // get random x coordinate
//            //let distr = GKRandomDistribution(lowestValue: Int(center.x - (self.frame.width / 2) * scene.camScale),
//                                             highestValue: Int(center.x + (self.frame.width / 2) * scene.camScale))
//            x = CGFloat(distr.nextInt())
//
//            // select top/bottom for y
//            //y = center.y + self.frame.height / 2 * scene.camScale + object.size.height * 2
//            y = Bool.random() ? y * -1 : y
//        } else {
//            // get random y coordinate
//            //let distr = GKRandomDistribution(lowestValue: Int(center.y - (self.frame.height / 2) * scene.camScale),
//                                             highestValue: Int(center.y + (self.frame.height / 2) * scene.camScale))
//            y = CGFloat(distr.nextInt())
//
//            // select left/right for x
//            //x = center.x + self.frame.width / 2 * scene.camScale + object.size.width * 2
//            x = Bool.random() ? x * -1 : x
//        }
//
//        return CGPoint(x: x, y: y)
//    }
    
    func setTimer() {
        for rate in spawnRates {
            let context = ["obj": rate.obj]
            let name = rate.obj.sprite.name
            timers[name ?? "test"] = Timer.scheduledTimer(timeInterval: rate.rate,
            target: self,
            selector: #selector(spawnObject(timer:)),
            userInfo: context,
            repeats: true)
        }
        
        
//        destroyTimer = Timer.scheduledTimer(timeInterval: 1.0,
//                                             target: self,
//                                             selector: #selector(removeFreeNodes),
//                                             userInfo: nil,
//                                             repeats: true)
        
    }
    
    func setTimer(using rates: [SpawnRate]) {
        for timer in timers {
            timer.value.invalidate()
        }
        
        spawnRates = rates

    }

    func playerWarp() {
        print("warping")
        // spawn the head, add it to the area
        player.head.followingPiece = nil
        for piece in player.chain.truckPieces {
            piece.targetPiece = nil
            piece.followingPiece = nil
        }
        
        addObject(obj: player.head)
        
        // start a timer that spawns in each successive truck piece (after a short delay)
        timers["capsule"] =  Timer.scheduledTimer(timeInterval: 0.25,
                   target: self,
                   selector: #selector(warpPiece),
                   userInfo: nil,
                   repeats: true)
    }
    
    @objc func warpPiece() {
        // gets the first piece in the followers array that doesn't have a target
        var nextPieceOpt: TruckPiece?
        for p in player.chain.truckPieces {
            if p.targetPiece == nil {
                nextPieceOpt = p
                break
            }
        }
        
        // set that piece's target to head.getLastPiece() (the last piece in the connected chain)
        // add that piece to the area
        if let newPiece = nextPieceOpt {
            let target = player.head.getLastPiece()
            newPiece.targetPiece = target
            target.followingPiece = newPiece
            
            addObject(obj: newPiece)
        } else {
            timers["capsule"]?.invalidate()
        }

    }
    
    func addObject(obj: SpaceObject) {

//        if let name = obj.sprite.name {
//            obj.sprite.name = "local" + name
//        }
        
        // add object to objectsInArea
        // add object to scene
        if obj.sprite.parent == nil {
            objectsInArea[obj.sprite] = obj
            scene?.addChild(obj.sprite)
        }
    }
    
    func unloadArea() {
        // store objects to be shown on return in initial objects
        
        // clear all objects from scene
        
        // store lost truck pieces in uniqueItems
        // remove lost truck pieces from player array
        
    }
    

    func update(by delta: CGFloat) {
        // update background
        // update objects
        
        for object in objectsInArea {
            object.value?.move(by: delta)
            object.value?.update(by: delta)
//            if object.value.destroyed {
//                destroyedNodes.inse
//            }
        }
    }
    
    
    // TODO a lot of changes to this 
    @objc func removeFreeNodes() {
        let removedObjects = destroyedNodes
        destroyedNodes.removeAll()
    
        // remove asteroids and debris that have been destroyed by the player
        for i in removedObjects {
            objectsInArea[i]??.onDestroy()
            objectsInArea.removeValue(forKey: objectsInArea[i]??.sprite)
        }
        
       
        
        // remove asteroids and deris that are too far from player
        let playerX = player.head.sprite.position.x
        let playerY = player.head.sprite.position.y
        for a in objectsInArea {
            let position = a.value?.sprite.position
            if position!.x > (playerX + 3 * scene!.frameWidth) || position!.x < (playerX - 3 * scene!.frameWidth) {
                a.value?.sprite.removeFromParent()
                objectsInArea.removeValue(forKey: a.key)
            } else if position!.y > (playerY + 3 * scene!.frameHeight) || position!.y < (playerY - 3 * scene!.frameHeight){
                a.value?.sprite.removeFromParent()
                objectsInArea.removeValue(forKey: a.key)
            }
        }
       
    }
}


func generateTestArea(withScene scene: AreaScene) -> Area {
    var a = Area(scene: scene)
    
    
    let stoneInv = Inventory([.Stone: 15], [.Stone: 15])
    let radInv = Inventory([.Nuclear: 50], [.Nuclear: 10])
    let remInv = Inventory([.Precious: 5], [.Precious: 5])
    
    let stoneAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_normal"), (150, 350), (150, 350), stoneInv)
    let radAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_radioactive"), (150, 350), (150, 350), radInv)
    let remAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_precious"), (100, 275), (100, 275), remInv)
    
    let stoneRate = SpawnRate(obj: stoneAst, rate: 3)
    let radRate = SpawnRate(obj: radAst, rate: 5)
    let remRate = SpawnRate(obj: remAst, rate: 9)
    
    let spawnRate = [stoneRate, radRate, remRate]
    
    a.spawnRates = spawnRate
    a.uniqueItems = [SpaceStation()]
    
    let background = SKEmitterNode(fileNamed: "StarryBackground")
    background?.advanceSimulationTime(30)
    background?.zPosition = -100
    a.backgroundItems.append(background!)
    
    return a
}
