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
    var maxNum: Int?
}

class Area {
    var scene: AreaScene?
    
    var spawnRates: [SpawnRate]!
    var spawnTypes: [String:SpaceObject]
    var initialItems: [SpaceObject]?
    var uniqueItems: [SpaceObject]!

    var timers: [String: Timer] = [:]
    var spawnTimers: [String: Timer] = [:]
    
    var gameIsPaused = false

    var landmark: SpaceObject?
    
    var backgroundItems = [SKNode]()
    
    var objectsInArea: [SKSpriteNode? : SpaceObject?] = [:]
    
    var destroyedNodes = [SKSpriteNode]()

        
    // player object
    var player: Player!
    
    
    // array for randomaly choosing an asteroid to load
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    var debris = ["satellite", "cell_tower"]
    
    init(scene gameScene: AreaScene) {
        scene = gameScene
        let stoneInv = Inventory([.Stone: 15], [.Stone: 15])
        let radInv = Inventory([.Nuclear: 10], [.Nuclear: 10])
        let remInv = Inventory([.Precious: 5], [.Precious: 5])
        
        let stoneAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_normal"), (150, 350), (150, 350), stoneInv)
        let radAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_radioactive"), (150, 350), (150, 350), radInv)
        let remAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_precious"), (100, 275), (100, 275), remInv)
        let sat = Debris(1, SKSpriteNode(imageNamed: debris[0]), (500, 700), (300, 500), Inventory())
        let cell = Debris(1, SKSpriteNode(imageNamed: debris[1]), (500, 700), (300, 500), Inventory())
        
        spawnTypes = [asteroids[0]: stoneAst,
                      asteroids[1]: remAst,
                      asteroids[2]: radAst,
                      debris[0]: sat,
                      debris[1]: cell]
        
        let background = SKEmitterNode(fileNamed: "StarryBackground")
        background?.advanceSimulationTime(30)
        background?.zPosition = -100
        backgroundItems.append(background!)
        
        let ss = SpaceStation()
        //ss.spawn(at: CGPoint(x: CGFloat(Int.random(in: -300...300)), y: CGFloat(Int.random(in: 1000...1500))))//TODO change random ranges
        ss.spawn(at: CGPoint(x: 0, y: 1200))//Spawns such that player appears from the arm
        
        let enemyChain: [TruckPiece] = RivalTruckPiece.generateChain(with: 5, holding: [.Nuclear])
        print("ENEMY NAMES")
        for p in enemyChain {
            print("\(String(describing: p.sprite.name))")
        }
        
        warp(truckList: enemyChain, at: CGPoint(x: 400, y: -500))
        
        uniqueItems = [ss]
        initialItems = uniqueItems
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
        
        
        // start timers
        setTimer()
        
        // start garbage collection timer
        timers["garbage"] = Timer.scheduledTimer(timeInterval: 1.0,
        target: self,
        selector: #selector(removeFreeNodes),
        userInfo: nil,
        repeats: true)
        
        // reintroduce player
        warp(truckList: player.head.getAllPieces(), at: CGPoint(x: 0,y: 0))
        player.head.invincible = true
    }
    
    @objc func spawnObject(timer: Timer) {
        guard let context = timer.userInfo as? [String: SpaceObject] else { return }
        
        let spawnRad: CGFloat = (scene?.frame.width)! * 1.5
        let targetAngle = CGFloat.random(in: 0...2 * CGFloat.pi)
        let rotation = Bool.random() ? -2 * CGFloat.pi : 2 * CGFloat.pi
        let spawnPoint = getRandPos(for: player.head, radius: spawnRad)
        
        if (context["obj"]?.sprite.name == "asteroid") {
            let obj = (context["obj"] as? Asteroid)?.copy()
            let speed = CGFloat.random(in: 35...400)
            obj?.speed = speed
            obj?.targetAngle = targetAngle
            obj?.rotation = rotation
            obj?.spawn(at: spawnPoint)
            addObject(obj: obj!)
        } else if (context["obj"]?.sprite.name == "debris") {
            let obj = (context["obj"] as? Debris)?.copy()
            let speed = CGFloat.random(in: 15...100)
            obj?.speed = speed
            obj?.targetAngle = targetAngle
            obj?.rotation = rotation
            obj?.spawn(at: spawnPoint)
            
            // randomize inventory of debris
            var possInv: [Int] = []
            for i in stride(from: 5, to: 25, by: 5) {
                possInv.append(i)
            }
            let invSize = possInv.randomElement()!
            obj?.inventory = Inventory(max: invSize, starting: invSize, possibleTypes: [.Oxygen, .Water, .Scrap])
            addObject(obj: obj!)
        }
    }
    
    
    func getRandPos(for object: SpaceObject, radius: CGFloat) -> CGPoint {
        let angle = Double.random(in: 0...(2*Double.pi))
        let x = object.sprite.position.x + CGFloat(cos(angle))*radius
        let y = object.sprite.position.y + CGFloat(sin(angle))*radius
        
        return CGPoint(x: x, y: y)
    }
    


    func setTimer() {
        for rate in spawnRates {
            let context = ["obj": rate.obj]
            let name = rate.obj.sprite.name
            spawnTimers[name ?? "test"] = Timer.scheduledTimer(timeInterval: rate.rate,
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
    
    //Warps the given list of truckpieces in at the given point, with a slight delay between each piece appearing.
    func warp(truckList: [TruckPiece], at point: CGPoint) {
        
        print("WARPING \(String(describing: truckList[0].sprite.name))")
        var head: TruckPiece?
        for piece in truckList {
            print("\(String(describing: piece.sprite.name))")
            if piece.isHead {
                head = piece
            }
            piece.targetPiece = nil
            piece.followingPiece = nil
            piece.sprite.position = point
        }
        
        head!.spawn(at: point)
        addObject(obj: head!)
        
        
        let context = ["pieces": truckList, "point": point] as [String : Any]
        timers[head!.sprite.name!] =  Timer.scheduledTimer(timeInterval: 0.5 * Double(head!.xRange.0),
        target: self,
        selector: #selector(warpPiece),
        userInfo: context,
        repeats: true)
    }
    
    // activate releashing on pieces
    @objc func warpPiece(timer: Timer) {
        guard let context = timer.userInfo as? [String: Any] else { return }
        let truckList: [TruckPiece] = (context["pieces"]) as! [TruckPiece]
        let point: CGPoint = (context["point"]) as! CGPoint
        
        // gets the first piece in the array that doesn't have a target
        var nextPieceOpt: TruckPiece?
        var head: TruckPiece?
        for p in truckList {
            if !p.isHead && p.targetPiece == nil && p.sprite.parent == nil {
                nextPieceOpt = p
                break
            } else if p.isHead {
                head = p
            }
        }
        
        // set that piece's target to head.getLastPiece() (the last piece in the connected chain)
        // add that piece to the area
        if let newPiece = nextPieceOpt {
            head!.addToChain(adding: newPiece)
            newPiece.spawn(at: point)
            addObject(obj: newPiece)
        } else {
            timers[head!.sprite.name!]?.invalidate()
        }
    }
    
    func addObject(obj: SpaceObject) {

//        if let name = obj.sprite.name {
//            obj.sprite.name = "local" + name
//        }
        
        // add object to objectsInArea
        // add object to scene
        for n in obj.getChildren() {
            if n?.parent == nil {
                scene?.addChild(n!)
            }
        }
        
        objectsInArea[obj.sprite] = obj
    }
    
    func unloadArea() {
        // store objects to be shown on return in initial objects
        
        // clear all objects from scene
        
        // store lost truck pieces in uniqueItems
        // remove lost truck pieces from player array
        
    }
    

    func update(by delta: CGFloat) {
        if !gameIsPaused{
            
            // update background
            for n in backgroundItems {
                if let e = n as? SKEmitterNode {
                    e.particlePosition = player.head.sprite.position
                }
            }
            
            // update objects
            for object in objectsInArea {
                object.value?.move(by: delta)
                object.value?.update(by: delta)
    //            if object.value.destroyed {
    //                destroyedNodes.inse
    //            }
            }
        }
    }
    
    
    @objc func removeFarNodes() {
        let playerX = player.head.sprite.position.x
        let playerY = player.head.sprite.position.y
        
        for o in objectsInArea {
            let position = o.value?.sprite.position
            var remove = false
            if position!.x > (playerX + 3 * scene!.frameWidth) || position!.x < (playerX - 3 * scene!.frameWidth) {
                remove = true
            } else if position!.y > (playerY + 3 * scene!.frameHeight) || position!.y < (playerY - 3 * scene!.frameHeight){
                remove = true
            }
            
            if remove {
                if o.value!.sprite.name == "capsule" {
                    print("capsule far")
                } else if uniqueItems.contains(where: {object in
                    object.OBJECT_ID == o.value!.OBJECT_ID
                }) {
                    print("unique item far")
                }else {
                    o.value?.onDestroy()
                    objectsInArea.removeValue(forKey: o.key)
                }

            }
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
    
    func setArea(with spawns: [String : Double]) {
        for timer in spawnTimers {
            timer.value.invalidate()
        }
        
        for obj in objectsInArea {
            switch obj.key?.name {
            case "asteroid", "debris", "item":
                obj.value?.sprite.removeFromParent()
                objectsInArea.removeValue(forKey: obj.key)
            default:
                print(obj.key?.name)
                continue
            }
        }
        
        // setup spawnrates
        spawnRates = []
        for spawn in spawns.keys {
            spawnRates.append(SpawnRate(obj: spawnTypes[spawn]!, rate: TimeInterval(spawns[spawn]!)))
        }
        
        setTimer()
        
        var x: CGFloat = 0
        // after setting spawns reset player
        for capsule in player.head.getAllPieces() {
            capsule.sprite.position = CGPoint(x: x, y: 0)
            x -= capsule.sprite.size.height/2.0
        }
        
    }
    
}


func generateTestArea(withScene scene: AreaScene) -> Area {
    let a = Area(scene: scene)
    
    
    let stoneInv = Inventory([.Stone: 15], [.Stone: 15])
    let radInv = Inventory([.Nuclear: 50], [.Nuclear: 10])
    let remInv = Inventory([.Precious: 5], [.Precious: 5])
    
    let stoneAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_normal"), (150, 350), (150, 350), stoneInv)
    let radAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_radioactive"), (150, 350), (150, 350), radInv)
    let remAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_precious"), (100, 275), (100, 275), remInv)
    
    let stoneRate = SpawnRate(obj: stoneAst, rate: 1)
    let radRate = SpawnRate(obj: radAst, rate: 3)
    let remRate = SpawnRate(obj: remAst, rate: 6)
    
    let spawnRate = [stoneRate, radRate, remRate]
    
    a.spawnRates = spawnRate
    
    let ss = SpaceStation()
    //ss.spawn(at: CGPoint(x: CGFloat(Int.random(in: -300...300)), y: CGFloat(Int.random(in: 1000...1500))))//TODO change random ranges
    ss.spawn(at: CGPoint(x: 0, y: 1200))//Spawns such that player appears from the arm

    let enemyChain: [TruckPiece] = RivalTruckPiece.generateChain(with: 5, holding: [.Nuclear])
    print("ENEMY NAMES")
    for p in enemyChain {
        print("\(p.sprite.name)")
    }
    
    a.warp(truckList: enemyChain, at: CGPoint(x: 400, y: -500))
    
    a.uniqueItems = [ss]
    a.initialItems = a.uniqueItems
    
    let background = SKEmitterNode(fileNamed: "StarryBackground")
    background?.advanceSimulationTime(30)
    background?.zPosition = -100
    a.backgroundItems.append(background!)
    
    return a
}



