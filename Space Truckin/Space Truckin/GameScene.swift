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
//        head.move(by: delta)
//        chain.movePieces(by: delta)
        chain.updateFollowers()
    }
}
extension Player {
    init(_ head: TruckPiece) {
        self.head = head
        self.chain = TruckChain(head: head)
    }
    
    
}

struct DropDownMenu {
    //TODO: resize buttons to be proportional to screen
    var controller: SKSpriteNode
    var buttons: [SKSpriteNode]
    var offset: CGFloat
    var menuIsOpen = false
    
    func move(to position: CGPoint){
        controller.position = position
        
        for i in 0...buttons.count-1{
            buttons[i].position.x = controller.position.x
            let dif: CGFloat = offset*CGFloat((Float(i)+1.0))
            buttons[i].position.y = controller.position.y - dif
        }
        
    }
    
    func getButtons() -> [SKSpriteNode] {
        return buttons
    }
    
    mutating func add(_ button: SKSpriteNode, called name: String){
        button.position = controller.position
        button.zPosition = 99
        button.name = name
        button.isUserInteractionEnabled = false
        button.anchorPoint = controller.anchorPoint
        button.size = controller.size
        buttons.append(button)
    }

    mutating func clicked(){
        menuIsOpen = !menuIsOpen
        if menuIsOpen{
            let height = controller.size.height
            offset = height + height/10.0
            controller.texture = SKTexture(imageNamed: "Close_arrow")
        } else {
            offset = 0
            controller.texture = SKTexture(imageNamed: "Open_arrow")
        }
    }
    
    func stop(){
        for b in buttons{
            if b.name == "start" {
                b.name = "stop"
                b.texture = SKTexture(imageNamed: "Stop")
            } else if b.name == "stop" {
                b.name = "start"
                b.texture = SKTexture(imageNamed: "Start")
            }
        }
    }
    
}




class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    var stopped = false
    
    var frameWidth: CGFloat!
    var frameHeight: CGFloat!
    
    let cam = SKCameraNode()
    let scaleBounds = CGPoint(x: 2, y: 5)
    
    var camScale: CGFloat = 2 //TODO: If things on the screen are wrong this is likely the problem, verify on different screens
        
    var lastTime: TimeInterval?
    
    var showOffScreenPieces = false
    
    var background: SKEmitterNode!
    
    
    var menu: DropDownMenu!
    var touchedButton = false
    
    var objectsInScene: [SKSpriteNode? : SpaceObject] = [:]
    
    // array for randomaly choosing an asteroid to load
    var asteroids = ["asteroid_normal", "asteroid_precious", "asteroid_radioactive"]
    var debris = ["satellite_1", "cell_tower1"]
    
    var asteroidTimer : Timer!
    var gameIsPaused = false
    
    var musicPlayer: MusicPlayer!
    
    var explosions: [SKTexture]! //TODO: consider moving this to a better home
    var destroyedNodes: (Set<SKSpriteNode?>) = []
    var destroyTimer: Timer!
    var swarm = false


    override func didMove(to view: SKView) {
        // Initialize screen height and width
        frameWidth = self.frame.size.width
        frameHeight = self.frame.size.height
        
        // get rid of gravity
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        //TODO: decide wether to resize objects or accepts screen differences/advantages
        self.camera = cam
        let sprite = SKSpriteNode(imageNamed: "space_truck_cab")

        
        if swarm {
            player = Player(TruckPiece(sprite: sprite, durability: 2, size: 1, speed: 250, boostedSpeed: 500))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.head))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2"), target: player.head))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.head))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.head))
            
        } else {
            player = Player(TruckPiece(sprite: sprite, durability: 2, size: 1, speed: 250, boostedSpeed: 500))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.chain.getLastPiece()))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2"), target: player.chain.getLastPiece()))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.chain.getLastPiece()))
            player.chain.add(piece: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"), target: player.chain.getLastPiece()))
        }
        
        
        for c in player.chain.getAllPieces() {
            
            objectsInScene[c.sprite] = c
            
            self.addChild(c.sprite!)
            self.addChild(c.thruster)
        }
        
            
        
        background = SKEmitterNode(fileNamed: "StarryBackground")
        background.advanceSimulationTime(30)
        background.zPosition = -100
        self.addChild(background)
        
        // need better way to delegate position on screen
        let menuConroller: SKSpriteNode = SKSpriteNode(imageNamed: "Open_arrow")
        menuConroller.position = CGPoint(x: cam.position.x + frameWidth, y: cam.position.y + frameHeight)
        menuConroller.zPosition = 100
        menuConroller.name = "action menu"
        menuConroller.isUserInteractionEnabled = false
        menuConroller.anchorPoint = CGPoint(x: 1, y: 1)
        menuConroller.size = CGSize(width: frameWidth/5, height: frameHeight/5)
        menu = DropDownMenu(controller: menuConroller, buttons: [], offset: 0)
        
        menu.add(SKSpriteNode(imageNamed: "Mine"), called: "mine")
        menu.add(SKSpriteNode(imageNamed: "Map_button"), called: "map")
        menu.add(SKSpriteNode(imageNamed: "Cargo_button"), called: "cargo")
        menu.add(SKSpriteNode(imageNamed: "Stop"), called: "stop")
        menu.add(SKSpriteNode(imageNamed: "Pause"), called: "pause")
        
        self.addChild(menu.controller)
        
        let buttons = menu.getButtons()
        for b in buttons {
            self.addChild(b)
        }

//        let galaxy = SKEmitterNode(fileNamed: "GalaxyBackground")!
//        self.addChild(galaxy)
        
        
        // I'm putting this here because I was thinking about it.
        // different types of asteroids should have different size distributions as well as different
        // frequencies of occurence
        // timer for asteroids

        // also what if there were only a set number of mineable asteroids in any one area, forcing players to navigate elsewhere, as the player destroys more asteroids, more junk and smaller debris clutters the map
        asteroidTimer = Timer.scheduledTimer(timeInterval: 2.0,
                                             target: self,
                                             selector: #selector(spawnAsteroid),
                                             userInfo: nil,
                                             repeats: true)
        
        asteroidTimer = Timer.scheduledTimer(timeInterval: 8.0,
                                             target: self,
                                             selector: #selector(spawnDebris),
                                             userInfo: nil,
                                             repeats: true)
        
        destroyTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(removeFreeNodes),
                                             userInfo: nil,
                                             repeats: true)
        
        musicPlayer = MusicPlayer(mood: Mood.PRESENT, setting: Setting.ALL)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        let touchedNode = self.atPoint(pos)
        // checks which node was touched and preforms that action
        if let name = touchedNode.name {
            touchedButton = true
            switch name {
            case "action menu":
                menu.clicked()
            case "map":
                //TODO: switch to map view
                menu.clicked()
            case "cargo":
                menu.clicked()
            case "stop",
                 "start":
                menu.stop()
                stopped = !stopped
            case "mine":
                //TODO: start mining
                menu.clicked()
                //musicPlayer.interrupt(withMood: Mood.DARK)
                player.chain.mine(for: 1.5)
            case "pause":
                //TODO: need to actually pause the game
                gameIsPaused = true
                menu.clicked()
                musicPlayer.skip()
            case "capsule":
                print("tapped capsule")
            default:
                touchedButton = false
            }
        } else {
            touchedButton = false
        }
        if !touchedButton{
            player.head.changeAngleTo(point: pos)
        }

    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if !touchedButton{
            player.head.changeAngleTo(point: pos)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //player.chain.dash(angle: 0)
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
    
    /// UPDATE

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        var delta: CGFloat
        if let t = lastTime {
            delta = CGFloat(currentTime - t)
        } else {
            delta = 0
        }
        
        lastTime = currentTime
        
        
        if !stopped {
            player.update(by: delta)
        }
        
        
        // we could maybe do this in one bigger for-loop, looping through all children
        // in the scene, and executing move(by: delta) on every movable we encounter
        
        for object in objectsInScene {
            object.value.move(by: delta)
            object.value.update()
            if object.value.destroyed {
                destroyedNodes.insert(object.value.sprite)
            }
        }
        
        // reset center spawn location for background particles
        background.particlePosition = player.head.sprite.position
        updateCamera()
        
        menu.move(to: CGPoint(x: cam.position.x + frameWidth - frameWidth/10, y:  cam.position.y + frameHeight))
        
        musicPlayer.update()
        

        
        
    }
    
    func updateCamera() {
        cam.xScale = camScale
        cam.yScale = camScale
        cam.position = player.head.sprite.position
        
    }
    
    @objc func spawnDebris() {
        let debrisSprite = SKSpriteNode(imageNamed:debris[Int.random(in: 0..<debris.count)])
        
        let speed = CGFloat.random(in: 25...75)
        let targetAngle = CGFloat.random(in: 0...2 * CGFloat.pi)
        let rotation = Bool.random() ? -1 * CGFloat.pi : 1 * CGFloat.pi

        self.addChild(debrisSprite)
        
        let debris = Debris(1, debrisSprite, (450,600), (450,600), Inventory(), speed, rotation, targetAngle, CollisionCategories.ASTEROID_CATEGORY, CollisionCategories.TRUCK_CATEGORY, speed)
        
        let spawnPoint = getRandPos(for: debrisSprite)
        debris.spawn(at: spawnPoint)
        objectsInScene[debris.sprite] = debris
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
                           targetAngle,
                           CollisionCategories.ASTEROID_CATEGORY,
                           CollisionCategories.TRUCK_CATEGORY, speed)
        
        ast.spawn(at: spawnPoint)
        
        // add asteroid to asteroids
        objectsInScene[ast.sprite] = ast
    }
    
    // function returns random offscreen position for space object projectile
    func getRandPos(for object: SKSpriteNode) -> CGPoint {
        var x : CGFloat
        var y : CGFloat
        
        // pick x or y for object randomly
        let pickRandWidth = Bool.random()
        let center = CGPoint(x: player.head.sprite.position.x,
                             y: player.head.sprite.position.y)
        
        if pickRandWidth {
            // get random x coordinate
            let distr = GKRandomDistribution(lowestValue: Int(center.x - (self.frame.width / 2) * camScale),
                                             highestValue: Int(center.x + (self.frame.width / 2) * camScale))
            x = CGFloat(distr.nextInt())
            
            // select top/bottom for y
            y = center.y + self.frame.height / 2 * camScale + object.size.height * 2
            y = Bool.random() ? y * -1 : y
        } else {
            // get random y coordinate
            let distr = GKRandomDistribution(lowestValue: Int(center.y - (self.frame.height / 2) * camScale),
                                             highestValue: Int(center.y + (self.frame.height / 2) * camScale))
            y = CGFloat(distr.nextInt())
            
            // select left/right for x
            x = center.x + self.frame.width / 2 * camScale + object.size.width * 2
            x = Bool.random() ? x * -1 : x
        }
        
        return CGPoint(x: x, y: y)
    }
    
    
    // called when a collision happens
    
    // The problem we're having is that collisions are registered between sprites, and we need the
    // effects to act on the SpaceObjects that have the sprites as a component
    // Two potential fixes:
    // 1. Rework the SpaceObject class so it actually extends SKSpriteNode, inextricably linking the game
    // code and the sprite
    // 2. Figure out some way to associate a sprite with its SpaceObject
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        var firstObject: SpaceObject?
        var secondObject: SpaceObject?

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        //print("normal: \(contact.contactNormal)")
        
        //print( (firstBody.node as? SKSpriteNode)?.name )
        //print( (secondBody.node as? SKSpriteNode)?.name )

        if let sprite = firstBody.node as? SKSpriteNode{
            firstObject = objectsInScene[sprite]
        }
        
        if let sprite = secondBody.node as? SKSpriteNode{
            secondObject = objectsInScene[sprite]
        }

        //print("obj1: \(firstObject)")
        //print("obj2: \(secondObject)")

        if let object1 = firstObject, let object2 = secondObject {
            //print("objects")
            object1.onImpact(with: object2, contact)
            object2.onImpact(with: object1, contact)
        }
        
        /*
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0  {
            didColide(torpedo: firstBody.node as! SKSpriteNode, alien: secondBody.node as! SKSpriteNode)
        }
        */
        
    }
    
    func dropItems(itemNum n: Int, with item: Item, around point: CGPoint) {
        for i in 0..<n {
            let drop = DroppedItem(sprite: SKSpriteNode(imageNamed: DroppedItem.filenames[item.type.rawValue]), item: item, speed: 50, direction: CGFloat(i) * CGFloat(Double.pi) / 2)
            
            drop.spawn(at: CGPoint(x: point.x + 10 * CGFloat(i), y: point.y + 10 * CGFloat(i)))
            objectsInScene[drop.sprite] = drop
            self.addChild(drop.sprite)
        }
    }

    @objc func removeFreeNodes() {
        let removedObjects = destroyedNodes
        destroyedNodes.removeAll()
    
        // remove asteroids and debris that have been destroyed by the player
        for i in removedObjects {
            print("boom")
            objectsInScene[i]?.onDestroy()
            objectsInScene.removeValue(forKey: objectsInScene[i]?.sprite)
        }
        
       
        
        // remove asteroids and deris that are too far from player
        let playerX = player.head.sprite.position.x
        let playerY = player.head.sprite.position.y
        for a in objectsInScene {
            let position = a.value.sprite.position
            if position.x > (playerX + 3 * frameWidth) || position.x < (playerX - 3 * frameWidth) {
                a.value.sprite.removeFromParent()
                objectsInScene.removeValue(forKey: a.key)
            } else if position.y > (playerY + 3 * frameHeight) || position.y < (playerY - 3 * frameHeight){
                a.value.sprite.removeFromParent()
                objectsInScene.removeValue(forKey: a.key)
            }
        }
       
    }
}
