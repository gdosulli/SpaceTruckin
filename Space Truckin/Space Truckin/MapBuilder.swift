//
//  MapBuilder.swift
//  Space Truckin
//
//  Created by Benjamin Temkin on 11/12/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


class Map {
    var mapOf: String
    
    var map: Array<Array<String>> = []
    var height: Int
    var width: Int
    
    var offsetX:CGFloat!
    var offsetY: CGFloat!
    
    var mapView: SKSpriteNode!
    var infoScreen: SKSpriteNode!
    var sectorViews: [SKSpriteNode] = []
    var labels: [SKLabelNode] = []
    let FONT = "Chalkduster"
    
    var danger: Int = 0 // what objects are allowed to spawn
    var risk: Int = 15 // how fast they spawn
    var intensity: Int = 0 // how many objects can be in one zone
    
    let FREQUENTLY = 4
    let MODERATELY = 8
    let RARELY = 13
    
    
    var fastTravel: [SKTexture] = []
    let travelScreen = SKSpriteNode(imageNamed: "travel0")
    let cockPit: SKSpriteNode! = SKSpriteNode(imageNamed: "cockpit")
    
    let allObjects = [0: "A", 1: "D", 2:"T"] //TODO: T is place holder remove from here and full name dictionary below
    let allObjectsFullNames = ["A": "Asteroids", "D": "Debris", "T": "Tests"]
    var possibleObjects: Array<String> = []
    
    var currentLocation: (Int, Int)
    var playerLabel: SKLabelNode!
    
    init(sizeOf area: (Int, Int), threat level: Int, maxObjects perZone: Int, named name: String, frame size: CGSize) {
        height = area.0 - 1
        width = area.1 - 1
        danger = level
        intensity = perZone
        currentLocation = (Int.random(in: 0...width), Int.random(in: 0...height))
        mapOf = name
                
        for _ in 0...width {
            var layer: Array<String> = []
            for _ in 0...height {
                layer.append(randZone())
            }
            map.append(layer)
        }
        generateMap(CGSize(width: size.width * 1.3, height: size.height * 1.3))
        
        travelScreen.addChild(cockPit)
    }
    
    init(with givenMap: Array<Array<String>>, sizeOf area: (Int, Int), threat level: Int, starting location: (Int, Int), named name: String, frame size: CGSize) {
        map = givenMap
        height = area.0 - 1
        width = area.1 - 1
        danger = level
        intensity = 0
        currentLocation = location
        mapOf = name
        generateMap(CGSize(width: size.width * 1.3, height: size.height * 1.3))
        
        travelScreen.addChild(cockPit)
    }
    
    func randZone() -> String {
        var zoneKey: String = ""
        var objects: Set<String> = []
        var localDanger = danger
        
        
        
        for _ in 0...intensity {
            let check = objects.count
            var addObject = Int.random(in: 0...localDanger)
            if addObject >= allObjects.count {
                addObject = allObjects.count - Int.random(in: allObjects.count/2...allObjects.count-1)
            }
            objects.insert(allObjects[addObject]!)
            if check < objects.count {
                localDanger -= addObject
            }
        }
        
        zoneKey += String(danger - localDanger) + "/"
        
        for object in objects {
            zoneKey += object
            zoneKey += String(Int.random(in: 2...risk)) + "/"
        }
        
        return zoneKey
    }
    
    func printMap() {
        print(map)
        print(currentLocation)
        for row in map {
            print(row)
        }
    }
    
    func showMap() {
        mapView.isHidden = !mapView.isHidden
        
        let currSector = "Sector " + String(currentLocation.0) + "-" + String(currentLocation.1)
        playerLabel.removeFromParent()
        for sector in sectorViews {
            sector.isHidden = !sector.isHidden
            if sector.name == currSector {
                if sector.size.height < sector.size.width {
                    playerLabel.fontSize = sector.size.height/8
                } else {
                    playerLabel.fontSize = sector.size.width/16
                }
                playerLabel.position = CGPoint(x: sector.size.width/2, y: 0 - sector.size.height/12 - sector.size.height/2 - playerLabel.fontSize)
                playerLabel.name = sector.name
                sector.addChild(playerLabel)
            }
      }
        if infoScreen.isHidden == false {
            infoScreen.isHidden = true
        }
    }
    
    func generateMap(_ frameSize: CGSize) {
        travelScreen.isHidden = true
        offsetX = frameSize.width/80
        offsetY = frameSize.height/80
        let grayBox = UIColor(cgColor: CGColor(red: 0.57, green: 0.57, blue: 0.57, alpha: 1))
        
        let mapBackground = SKSpriteNode(imageNamed: "ComputerFrameXL")
        mapBackground.position = CGPoint(x: 0, y: 0)
        mapBackground.zPosition = 100
        mapBackground.name = "sectorMap"
        mapBackground.isUserInteractionEnabled = false
        mapBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mapBackground.isHidden = true
        mapBackground.size = CGSize(width: frameSize.width*1.1, height: frameSize.height*1.2)
        
        mapView = mapBackground
        
        let mapInfo = SKSpriteNode(color: grayBox, size: frameSize)
        mapInfo.position = CGPoint(x: 0, y: 0)
        mapInfo.zPosition = 102
        mapInfo.name = "info"
        mapInfo.isUserInteractionEnabled = false
        mapInfo.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mapInfo.isHidden = true
        
        infoScreen = mapInfo
        
        let jumpButton = SKSpriteNode(imageNamed: "jump")
        jumpButton.name = "jump"
        jumpButton.position = CGPoint(x: infoScreen.size.width/4, y: 0 - infoScreen.size.height/4)
        jumpButton.size = CGSize(width: infoScreen.size.width/5, height: infoScreen.size.height/5)
        let returnButton = SKSpriteNode(imageNamed: "return")
        returnButton.name = "return"
        returnButton.position = CGPoint(x: 0 - infoScreen.size.width/4, y: 0 - infoScreen.size.height/4)
        returnButton.size = jumpButton.size
        infoScreen.addChild(returnButton)
        infoScreen.addChild(jumpButton)
        
        let playerIndicator = SKLabelNode(fontNamed: FONT)
        playerIndicator.text = "[You are here]"
        playerIndicator.fontColor = SKColor.green
        playerIndicator.isUserInteractionEnabled = false
        
        playerLabel = playerIndicator
        
        for i in 0...width {
            for j in 0...height {
                let sectorInfo: [String: String] = getSectorInfo(map[i][j])
                print(sectorInfo)
                var dangerGradient: Double = 1.0
                if let secDanger = sectorInfo["sectorDanger"] {
                    if let secDangerVal = Double(secDanger) {
                        dangerGradient = secDangerVal / Double(danger)
                    }
                }
                
                let sector = SKSpriteNode(color: UIColor(red: CGFloat(dangerGradient), green: 0.1961, blue: CGFloat(1 - dangerGradient), alpha: 0.75), size: CGSize(width:  frameSize.width/CGFloat(width + 1) - offsetX - offsetX/CGFloat(width + 1), height: frameSize.height/CGFloat(height + 1) - offsetY - offsetY/CGFloat(height + 1)))
                sector.zPosition = 101
                sector.name = map[i][j]
                sector.isUserInteractionEnabled = false
                sector.anchorPoint = CGPoint(x: 0, y: 1)
                
                let sectorX = mapBackground.position.x + offsetX * CGFloat(i + 1) + sector.size.width * CGFloat(i)
                let sectorY = mapBackground.position.y - offsetY * CGFloat(j + 1) - sector.size.height * CGFloat(j)
                sector.position = CGPoint(x: sectorX - frameSize.width/2, y: sectorY + frameSize.height/2)
                
                sector.isHidden = true
                sector.name = "Sector " + String(i) + "-" + String(j)
                
                
                let label = SKLabelNode(fontNamed: FONT)
                label.text = "Sector " + String(i) + "-" + String(j)
                if sector.size.height < sector.size.width {
                    label.fontSize = sector.size.height/5
                } else {
                    label.fontSize = sector.size.width/10
                }
                
                label.fontColor = SKColor.black
                label.position = CGPoint(x: sector.size.width/2, y: 0 - sector.size.height/12 - sector.size.height/2)
                label.name = sector.name
                label.isUserInteractionEnabled = false
                
                sector.addChild(label)
                
                sectorViews.append(sector)
            }
        }
    }
    
    func removeMap() {
        if mapView.parent != nil {
            mapView.removeFromParent()
        }
        for sector in sectorViews {
           sector.removeFromParent()
        }
        infoScreen.removeFromParent()
    }
    
    func getSectorInfo(_ secName: String) -> [String: String]{
        var info: [String: String] = [:]
        let rawData = secName.split(separator: "/")
        info["sectorDanger"] = String(rawData[0])
        for i in 0...allObjects.count - 1 {
            if let object = allObjects[i] {
                for j in 1...rawData.count - 1 {
                    if rawData[j].contains(object) {
                        var rate = ""
                        for c in rawData[j] {
                            if String(c) != object {
                                rate += String(c)
                            }
                        }
                        info[object] = rate
                    }
                }
            }
            
        }
        return info
    }
    
    func moveMap(to point: CGPoint) {
        for sector in sectorViews {
            sector.position = CGPoint(x: sector.position.x - (mapView.position.x - point.x + offsetX * 2), y: sector.position.y - (mapView.position.y - point.y))
        }
        infoScreen.position = CGPoint(x: infoScreen.position.x - (mapView.position.x - point.x + offsetX * 2), y: infoScreen.position.y - (mapView.position.y - point.y))
        travelScreen.position = point
        mapView.position = CGPoint(x: mapView.position.x - (mapView.position.x - point.x + offsetX * 2), y: mapView.position.y - (mapView.position.y - point.y))
        
        
    }
    
    func showInfo(about sector: String){
        for c in infoScreen.children {
            if c.name != "jump" && c.name != "return" {
                c.removeFromParent()
            }
        }
        let areaCode = sector.split(separator: " ")
        let rawData = areaCode[1].split(separator: "-")
        var info: [String: String] = [:]
        if let x = Int(rawData[0]) {
            if let y = Int(rawData[1]) {
                info = getSectorInfo(map[x][y])
                if let jumpButton = infoScreen.childNode(withName: "jump") {
                    if (x, y) == currentLocation {
                        jumpButton.isHidden = true
                    } else {
                        jumpButton.isHidden = false
                    }
                }
            }
        }
        
        var dangerGradient: Double = 1.0
        if let secDanger = info["sectorDanger"] {
            if let secDangerVal = Double(secDanger) {
                dangerGradient = secDangerVal / Double(danger)
            }
        }
        
        var fontSize: CGFloat
        if infoScreen.size.height < infoScreen.size.width {
            fontSize = infoScreen.size.height/CGFloat(Double(info.count + 1) * 2.5)
        } else {
            fontSize = infoScreen.size.width/CGFloat(Double(info.count + 1) * 2.5)
        }
        
        var label = SKLabelNode(fontNamed: FONT)
        var dangerClassifier = ""
        if dangerGradient > 0.75 {
            dangerClassifier = "High"
        } else if dangerGradient > 0.40 {
            dangerClassifier = "Medium"
        } else {
            dangerClassifier = "Low"
        }
        
        var textHeight = infoScreen.size.height/2 - fontSize
        
        label.text = sector
        label.fontSize = fontSize
        label.fontColor = SKColor.black
        label.position = CGPoint(x: 0, y: textHeight)
        label.isUserInteractionEnabled = false
        
        infoScreen.addChild(label)
        
        label = SKLabelNode(fontNamed: FONT)
        label.text = "Relative Danger: " + dangerClassifier
        label.fontSize = fontSize * 0.7
        label.fontColor = UIColor(red: CGFloat(dangerGradient), green: 0.1961, blue: CGFloat(1 - dangerGradient), alpha: 1)
        textHeight = textHeight - fontSize
        label.position = CGPoint(x: 0, y: textHeight)
        
        infoScreen.addChild(label)
        
        for i in 0...allObjects.count - 1 {
            if let value = allObjects[i] {
                if let spawnRate = info[value] {
                    var rarity: String = ""
                    var colorRarity: UIColor = UIColor.black
                    if let rate = Int(spawnRate){
                        if rate <= FREQUENTLY {
                            rarity = "Very Common"
                            colorRarity = UIColor.green
                        } else if rate <= MODERATELY {
                            rarity = "Common"
                            colorRarity = UIColor.blue
                        } else {
                            rarity = "Rare"
                            colorRarity = UIColor.yellow
                        }
                    }
                    label = SKLabelNode(fontNamed: FONT)
                    if let name = allObjectsFullNames[value] {
                        label.text = name + ": " + rarity
                    }
                    label.fontSize = fontSize * 0.7
                    label.fontColor = colorRarity
                    textHeight = textHeight - fontSize
                    label.position = CGPoint(x: 0, y: textHeight)
                    
                    infoScreen.addChild(label)
                }
            }
        }
        infoScreen.isHidden = false
    }
    
    func travel(to sectorName: String) {
        let areaCode = sectorName.split(separator: " ")
        let rawData = areaCode[1].split(separator: "-")
        if let x = Int(rawData[0]) {
            if let y = Int(rawData[1]) {
                currentLocation = (x, y)
            }
        }
    }
    func animateTravel(on scene: SKScene, with size: CGSize) {
        if fastTravel == [] {
            for i in 0...35 {
                let spaceTexture = "travel\(i)"
                fastTravel.append(SKTexture(imageNamed: spaceTexture))
              }
        }
        showTravelScreen()
        travelScreen.size = CGSize(width: size.width*2, height: size.height*2)
        travelScreen.zPosition = 1000
        
        cockPit.zPosition = 1001
        cockPit.size = travelScreen.size
        
        travelScreen.run(SKAction.animate(with: fastTravel, timePerFrame: 0.1, resize: false, restore: false), completion: {
            self.showTravelScreen()
        })
    }
    
    func showTravelScreen() {
        travelScreen.isHidden = !travelScreen.isHidden
    }
    func hideInfoScreen() {
        infoScreen.isHidden = true
    }
    
    func getSpawnTimes() -> [String : Double] {
        var spawnDelays: [String : Double] = [:]
        let info = getSectorInfo(map[currentLocation.0][currentLocation.1])
        for i in 0...allObjects.count - 1 {
            if let value = allObjects[i] {
                if let spawnRate = info[value] {
                    if let object = allObjectsFullNames[value] {
                        spawnDelays[object] = Double(spawnRate)
                    }
                }
            }
        }
                
        print(spawnDelays)
        return spawnDelays
    }
    
}

