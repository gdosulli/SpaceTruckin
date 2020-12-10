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
    let cam = SKCameraNode()
    
    func getChildren() -> [SKNode?] {
        return head.getAllChainedChildren()
    }
    
    func getClickedPiece(from node: SKSpriteNode) -> TruckPiece? {
        for piece in head.getAllPieces() {
            if piece.sprite === node {
                return piece
            }
        }
        return nil
    }
    
    func setBoost(b: Bool) {
        for p in head.getAllPieces() {
            p.setBoost(b: false)
        }
        
        var truckPiece: TruckPiece?
        truckPiece = head
        while truckPiece != nil {
            truckPiece?.setBoost(b: b)
            truckPiece = truckPiece?.followingPiece
        }
    }
    
    func getInventory() -> Inventory {
        var maxCapacities = [ItemType:Int]()
        var items = [ItemType:Int]()
        for type in ItemType.allCases {
            maxCapacities[type] = 0
            items[type] = 0
        }
        
        for piece in head.getAllPieces() {
            for type in ItemType.allCases {
                maxCapacities[type]! += piece.inventory.getMaxCapacity(for: type)
                items[type]! += piece.inventory.getCurrentCapacity(for: type)
            }
        }
        
        return Inventory(maxCapacities, items)
    }
}
extension Player {
    init(_ head: TruckPiece) {
        self.head = head
        head.isHead = true
    }
}

struct DropDownMenu {
    //TODO: resize buttons to be proportional to screen
    var controller: SKSpriteNode
    var buttons: [SKSpriteNode]
    var offset: CGFloat
    var menuIsOpen = false
    
    var map: Map!
    var infoScreen: InfoScreen!
    var viewingSector: String!
    
    func move(menu position: CGPoint, map center: CGPoint, on scene: SKScene){
        controller.position = position
        
        for i in 0...buttons.count-1{
            buttons[i].position.x = controller.position.x
            let dif: CGFloat = offset*CGFloat((Float(i)+1.0))
            buttons[i].position.y = controller.position.y - dif
        }
        
        map.moveMap(to: center)
        infoScreen.background.position = map.mapView.position
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
    
    mutating func setMap(with newMap: Map, on scene: SKScene) {
        if map != nil {
            map.removeMap()
        }
        map = newMap
        scene.addChild(map.mapView)
        scene.addChild(map.infoScreen)
        for sector in map.sectorViews {
            scene.addChild(sector)
        }
        scene.addChild(map.travelScreen)
    }
    
    mutating func setInfoScreen(with newInfoScreen: InfoScreen, on scene: SKScene) {
        infoScreen = newInfoScreen
        scene.addChild(infoScreen.background)
    }
    
    func updateInfoScreen(_ inventory: Inventory) {
        infoScreen.update(inventory)
    }
    
    mutating func showInfoScreen() {
        infoScreen.show()
        if !map.mapView.isHidden {
            map.showMap()
        }
    }
    
    mutating func showMap() {
        map.showMap()
        if !infoScreen.background.isHidden {
            infoScreen.show()
        }
    }
    
    mutating func viewSector(named name: String) {
        viewingSector = name
        map.showInfo(about: name)
    }
    
    mutating func travel() -> [String : Double] {
        map.travel(to: viewingSector)
        closeTabs()
        if menuIsOpen {
            clicked()
        }
        return map.getSpawnTimes()
    }
    
    mutating func closeTabs() {
        if !map.mapView.isHidden {
            map.showMap()
        }
        if !infoScreen.background.isHidden {
            infoScreen.show()
        }
    }
    
}


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

        
        let player = Player(TruckPiece(sprite: sprite,
                                       durability: 2,
                                       size: 1.3,
                                       speed: 250,
                                       boostedSpeed: 500,
                                       inventory: Inventory(for: .Oxygen, max: 100, starting: 100)))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"),
                                                  inventory: Inventory(for: .Water, max: 100, starting: 100)))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule2"),
                                                  inventory: Inventory(for: .Precious, max: 100, starting: 0)))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"),
                                                  inventory: Inventory(for: .Stone, max: 100, starting: 0)))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"),
                                                  inventory: Inventory(for: .Scrap, max: 100, starting: 0)))
        player.head.addToChain(adding: TruckPiece(sprite: SKSpriteNode(imageNamed: "space_truck_capsule1"),
                                                  inventory: Inventory(for: .Nuclear, max: 100, starting: 0)))
    
        currentArea = Area(scene: self)
        currentArea.player = player
    
        
        // need better way to delegate position on screen
        let menuController: SKSpriteNode = SKSpriteNode(imageNamed: "Open_arrow")
        menuController.position = CGPoint(x: cam.position.x + frameWidth, y: cam.position.y + frameHeight)
        menuController.zPosition = 100
        menuController.name = "action menu"
        menuController.isUserInteractionEnabled = false
        menuController.anchorPoint = CGPoint(x: 1, y: 1)
        menuController.size = CGSize(width: frameWidth/5, height: frameHeight/5)
        menu = DropDownMenu(controller: menuController, buttons: [], offset: 0)
        
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
        
        let selectedPiece = player.head.getFirstPiece()
        let capsule = SKSpriteNode(imageNamed: "space_truck_cab")
        //capsule.setScale(0.95)
        capsule.zPosition = 100
        capsule.isUserInteractionEnabled = false
        capsule.anchorPoint = CGPoint(x: 1, y: 1)
        //capsule.size = CGSize(width: frameWidth/5, height: frameHeight/5)
        self.addChild(capsule)
        let durLabel = SKLabelNode(fontNamed: "Futura-CondensedMedium")
        durLabel.fontSize = frameWidth/18
        durLabel.zPosition = 100
        durLabel.fontColor = UIColor.white
        durLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        self.addChild(durLabel)
        for type in ItemType.allCases {
            let item = SKSpriteNode(imageNamed: DroppedItem.filenames[type.rawValue])
            item.zPosition = 100
            item.isUserInteractionEnabled = false
            item.anchorPoint = CGPoint(x: 1, y: 1)
            item.size = CGSize(width: frameWidth/8, height: frameWidth/8)
            self.addChild(item)
            var bar: InterfaceBar
            if type == .Oxygen {
                bar = createFuelBar(size:  CGSize(width: frameWidth * 0.2, height: frameHeight * 0.05))
            } else {
                bar = createStorageBar(size: CGSize(width: frameWidth * 0.2, height: frameHeight * 0.05))
            }
            for child in bar.getChildren() {
                child.zPosition = 100
                self.addChild(child)
            }
            
            invTypes[type] = item
            invBars[type] = bar
        }
        
        selectedInventory = SelectedInventory(piece: selectedPiece,
                                              inventory: player.head.inventory,
                                              capsule: capsule,
                                              invTypes: invTypes,
                                              invBars: invBars,
                                              baseOpacity: 0.5,
                                              fadeInterval: 3,
                                              fadeTime: 1.5,
                                              frameWidth: frameWidth,
                                              frameHeight: frameHeight,
                                              durability: durLabel)
        // sets the map
        let testMap = Map(sizeOf: (4, 4), threat: 3, maxObjects: 3, named: "test Area", frame: CGSize(width: frameWidth, height: frameHeight))
        testMap.printMap()
        // comment out testMap above and uncomment this to use the original map
        //let testMap = Map(with: [["1/A2/D8/"]], sizeOf: (1, 1), threat: 3, starting: (0, 0), named: "test Area", frame: CGSize(width: frameWidth, height: frameHeight))
        menu.setMap(with: testMap, on: self)
        let infoScreen = InfoScreen(frameSize: testMap.mapView.size)
        menu.setInfoScreen(with: infoScreen, on: self)
        
        
        currentArea.setArea(with: menu.map.getSpawnTimes())
        
        for i in 2...6 {
            let drill = "space_truck_cab\(i)"
            drillAnim.append(SKTexture(imageNamed: drill))
            print(i)
        }
        
        TruckPiece.drillAnim = drillAnim

//        let galaxy = SKEmitterNode(fileNamed: "GalaxyBackground")!
//        self.addChild(galaxy)
        
        
        // I'm putting this here because I was thinking about it.
        // different types of asteroids should have different size distributions as well as different
        // frequencies of occurence
        // timer for asteroids

        // also what if there were only a set number of mineable asteroids in any one area, forcing players to navigate elsewhere, as the player destroys more asteroids, more junk and smaller debris clutters the map

        musicPlayer = MusicPlayer(mood: Mood.PRESENT, setting: Setting.ALL)
        
        
        // double tap recognizer
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTap.numberOfTapsRequired = 2
        
        self.scene?.view?.addGestureRecognizer(doubleTap)
        
        
        currentArea.loadArea()
    }
    

    func touchDown(atPoint pos : CGPoint) {
        print("TOUCHED")
        if currentArea.player.head.docked { //TODO: MOVE THIS
            print("DOCKEDTOUCHED")
            currentArea.player.head.undockChain()
        }
        
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
                menu.showMap()
            case "cargo":
                menu.showInfoScreen()
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
                currentArea.gameIsPaused = !currentArea.gameIsPaused
                menu.clicked()
                musicPlayer.skip()
            case "capsule":
                print("tap registered on capsule")
                if let selectedPiece = currentArea.player.getClickedPiece(from: touchedNode as! SKSpriteNode) {
                    selectedInventory.inventory = selectedPiece.inventory
                    selectedInventory.capsule.texture = selectedPiece.sprite.texture
                    selectedInventory.piece = selectedPiece
                    selectedInventory.resetOpacity()
                }
            case "sector page":
                menu.viewSector(named: name)
            case "jump":
                // TODO change area code
                currentArea.setArea(with: menu.travel())
                
                menu.map.animateTravel(on: self, with: self.frame.size)
            case "return" :
                menu.map.hideInfoScreen()
            case "infoScreen", "info":
                touchedButton = true
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
        if !touchedButton {
            print("double touch")
            currentArea.player.head.sprite.run(SKAction.sequence([SKAction.animate(with: drillAnim,
                                                                                   timePerFrame: 0.1,
                                                                                   resize: false,
                                                                                   restore: false),SKAction.repeatForever(SKAction.animate(with: TruckPiece.drillAnimation,
                                                                                                                     timePerFrame: 0.1,
                                                                                                                     resize: false,
                                                                                                                     restore: false))]))
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
        
        // update UI overlays
        selectedInventory.move(to: CGPoint(x: cam.position.x - frameWidth + frameWidth/5,
                                           y:  cam.position.y + frameHeight - frameHeight/10))
        selectedInventory.update(currentTime)
        
        menu.move(menu: CGPoint(x: cam.position.x + frameWidth - frameWidth/10, y:  cam.position.y + frameHeight), map: cam.position, on: self)
        menu.updateInfoScreen(currentArea.player.getInventory())
        
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

    func didEnd(_ contact: SKPhysicsContact) {
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
        
        if let sprite = firstBody.node as? SKSpriteNode{
                 firstObject = currentArea.objectsInArea[sprite] as? SpaceObject
             }
             
             if let sprite = secondBody.node as? SKSpriteNode{
                 secondObject = currentArea.objectsInArea[sprite] as? SpaceObject
             }

             if let object1 = firstObject, let object2 = secondObject {
                 object1.onImpactEnded(with: object2, contact)
                 object2.onImpactEnded(with: object1, contact)
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

        if let sprite = firstBody.node as? SKSpriteNode{
            firstObject = currentArea.objectsInArea[sprite] as? SpaceObject
        }
        
        if let sprite = secondBody.node as? SKSpriteNode{
            secondObject = currentArea.objectsInArea[sprite] as? SpaceObject
        }

        if let object1 = firstObject, let object2 = secondObject {
            object1.onImpact(with: object2, contact)
            object2.onImpact(with: object1, contact)
        }
        
    }

}
