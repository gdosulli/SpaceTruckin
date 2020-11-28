//
//  GameScene.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit
import GameplayKit

class AreaScene: SKScene, SKPhysicsContactDelegate {
    var stopped = false
    
    var selectedInventory: SelectedInventory!
    
    var frameWidth: CGFloat!
    var frameHeight: CGFloat!
    
    
    var camTarget: SpaceObject?
    var camTargetPoint: CGPoint?
    let cam = SKCameraNode()
    
    let scaleBounds = CGPoint(x: 2, y: 5)
    var camScale: CGFloat = 2 //TODO: If things on the screen are wrong this is likely the problem, verify on different screens
    
    // must be set to current time on unpause
    var lastTime: TimeInterval?
    
    // probably deprecated
    var showOffScreenPieces = false
        
    var menu: DropDownMenu!
    var touchedButton = false
        
    
    var musicPlayer: MusicPlayer!
    var sfxPlayer: MusicPlayer?
    
    var muteSound = false
    
    var currentArea: Area!
    
    var boostLocked = false
    
    var drillAnim:[SKTexture] = []


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

        
        let player = Player(TruckPiece(sprite: sprite, durability: 2, size: 1.3, speed: 250, boostedSpeed: 500, inventory: Inventory()))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2")))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
//        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
//        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
//        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2")))
//        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
//        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1")))
    
        currentArea = generateTestArea(withScene: self)
        currentArea.player = player
    
        
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
        
        var invTypes = [ItemType:SKSpriteNode]()
        var invBars = [ItemType:InterfaceBar]()
        
        let capsule = SKSpriteNode(imageNamed: "space_truck_cab")
        capsule.setScale(0.75)
        capsule.zPosition = 100
        capsule.isUserInteractionEnabled = false
        capsule.anchorPoint = CGPoint(x: 1, y: 1)
        //capsule.size = CGSize(width: frameWidth/5, height: frameHeight/5)
        self.addChild(capsule)
        for type in ItemType.allCases {
            let item = SKSpriteNode(imageNamed: DroppedItem.filenames[type.rawValue])
            item.zPosition = 100
            item.isUserInteractionEnabled = false
            item.anchorPoint = CGPoint(x: 1, y: 1)
            item.size = CGSize(width: frameWidth/8, height: frameWidth/8)
            self.addChild(item)
            
            let bar = createStorageBar(size: CGSize(width: frameWidth * 0.2,
                                                    height: frameHeight * 0.05))
            for child in bar.getChildren() {
                child.zPosition = 100
                self.addChild(child)
            }
            
            invTypes[type] = item
            invBars[type] = bar
        }
        
        selectedInventory = SelectedInventory(inventory: player.head.inventory,
                                              capsule: capsule,
                                              invTypes: invTypes,
                                              invBars: invBars,
                                              baseOpacity: 0.5,
                                              fadeInterval: 3,
                                              fadeTime: 1.5,
                                              frameWidth: frameWidth,
                                              frameHeight: frameHeight)
        // sets the map
        let testMap = Map(sizeOf: (4, 4), threat: 3, maxObjects: 1, named: "test Area", frame: CGSize(width: frameWidth, height: frameHeight))
        
        // comment out testMap above and uncomment this to use the original map
        //let testMap = Map(with: [["1/A2/D8/"]], sizeOf: (1, 1), threat: 3, starting: (0, 0), named: "test Area", frame: CGSize(width: frameWidth, height: frameHeight))
        menu.setMap(with: testMap, on: self)
        
        for i in 2...6 {
            let drill = "space_truck_cab\(i)"
            drillAnim.append(SKTexture(imageNamed: drill))
            print(i)
        }

//        let galaxy = SKEmitterNode(fileNamed: "GalaxyBackground")!
//        self.addChild(galaxy)
        
        
        // I'm putting this here because I was thinking about it.
        // different types of asteroids should have different size distributions as well as different
        // frequencies of occurence
        // timer for asteroids

        // also what if there were only a set number of mineable asteroids in any one area, forcing players to navigate elsewhere, as the player destroys more asteroids, more junk and smaller debris clutters the map

        musicPlayer = MusicPlayer(mood: Mood.PRESENT, setting: Setting.ALL)
        
        
        // double tap stuff
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        
        self.scene?.view?.addGestureRecognizer(doubleTap)
        
        
        currentArea.loadArea()
    }
    

    func touchDown(atPoint pos : CGPoint) {
        let touchedNode = self.atPoint(pos)
        // checks which node was touched and preforms that action
        if let name = touchedNode.name {
            var realName = name
            if name.contains("Sector ") {
                realName =  "sector page"
            }
            touchedButton = true
            switch realName {
            case "action menu":
                menu.clicked()
            case "map":
                //TODO: switch to map view
                menu.map.showMap()
            case "cargo":
                camScale += 1
                menu.clicked()
            case "stop",
                 "start":
                menu.stop()
                currentArea.player.head.circle = !currentArea.player.head.circle
                stopped = !stopped
            case "mine":
                //TODO: start mining
                //menu.clicked()
                //musicPlayer.interrupt(withMood: Mood.DARK)
                //player.chain.mine(for: 1.5)
                currentArea.player.setBoost(b: true)
            case "pause":
                //TODO: need to actually pause the game
                currentArea.gameIsPaused = true
                menu.clicked()
                musicPlayer.skip()
            case "capsule":
                touchedButton = false
                print("tap registered on capsule")
                if let selectedPiece = currentArea.player.getClickedPiece(from: touchedNode as! SKSpriteNode) {
                    print("tapped \(selectedPiece.sprite.name)")

                    selectedInventory.inventory = selectedPiece.inventory
                    selectedInventory.capsule.texture = selectedPiece.sprite.texture
                    selectedInventory.resetOpacity()
                }
            case "sector page":
                menu.viewSector(named: name)
            case "jump":
                // TODO change area code
                //setTimer(using: menu.travel())
                musicPlayer.muted = false
                musicPlayer.unmute()
                musicPlayer.playSong(MySongs.JUMP)
                musicPlayer.getPlaylist()
                
                menu.map.animateTravel(on: self, with: self.frame.size)
            case "return" :
                menu.map.hideInfoScreen()
            default:
                touchedButton = false
            }
        } else {
            touchedButton = false
        }
        if !touchedButton{
            currentArea.player.head.circle = false
            currentArea.player.head.changeAngleTo(point: pos)
        }

    }
    
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer) {
        print("double touch")
        currentArea.player.head.sprite.run(SKAction.animate(with: drillAnim,
                                                            timePerFrame: 0.1,
                                                            resize: false,
                                                            restore: false))
        currentArea.player.setBoost(b: true)
        boostLocked = true
        let duration = 0.05
        let unlockDate = Date().addingTimeInterval(duration)
        let timer = Timer(fireAt: unlockDate,
                          interval: 0,
                          target: self,
                          selector: #selector(unlockBoost),
                          userInfo: nil,
                          repeats: false)
        RunLoop.main.add(timer, forMode: .common)

    }
    
    @objc func unlockBoost() {
        boostLocked = false
        print("unlocked")
    }
    
    
    func touchMoved(toPoint pos : CGPoint) {
        if !touchedButton{
            currentArea.player.head.changeAngleTo(point: pos)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        //player.chain.dash(angle: 0)
        if currentArea.player.head.boosted {
            if !boostLocked {
                currentArea.player.setBoost(b: false)
                currentArea.player.head.sprite.run(SKAction.animate(with: drillAnim.reversed(),
                                                                    timePerFrame: 0.1,
                                                                    resize: false,
                                                                    restore: false))
            }
        }
        
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
    
    // TODO: I wanna be able to zoom in and out on the screen
    // I also wanna be able to slow down and speed up
    
    // You might wanna slow down if you're in an area with too many other ships
    // Maybe certain areas will be "Stellar No-Wake Zones" where cops swarm you if you're caught speeding
    // or carrying illegal contraband

    override func update(_ currentTime: TimeInterval) {
        // get delta
        var delta: CGFloat
        if let t = lastTime {
            delta = CGFloat(currentTime - t)
        } else {
            delta = 0
        }
        
        if delta > 0.5 {
            delta = 0.01
        }
        lastTime = currentTime
        
        // update everything in area
        currentArea.update(by: delta)
        
        updateCamera()
        
        // ui stuff
        
        selectedInventory.move(to: CGPoint(x: cam.position.x - frameWidth + frameWidth/5,
                                           y:  cam.position.y + frameHeight - frameHeight/10))
        selectedInventory.update(currentTime)
        
        menu.move(menu: CGPoint(x: cam.position.x + frameWidth - frameWidth/10, y:  cam.position.y + frameHeight), map: cam.position, on: self)
        
        // sound stuff
        musicPlayer.update()
        
    }
    
    func updateCamera() {
        cam.xScale = camScale
        cam.yScale = camScale
        if !currentArea.player.head.circle {
            cam.position = currentArea.player.head.sprite.position
        }
    }

    

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
            firstObject = currentArea.objectsInArea[sprite] as? SpaceObject
        }
        
        if let sprite = secondBody.node as? SKSpriteNode{
            secondObject = currentArea.objectsInArea[sprite] as? SpaceObject
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

}
