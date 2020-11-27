//
//  Spawner.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/24/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import GameplayKit

class Spawner: SpaceObject {
    // spawner is gonna be able to spawn objects in a certain area, going in certain directions at certain speeds
    
    // it would also keep track of it's objects, and could act on them within update
    
    // it will have a sprite that covers the entire spawnable area and will be usually set to isHidden
    
    // getRandSpawnPosition() -> CGPoint will return a random point on the sprite from which to spawn
    
    // update()
    var spawnedObjects: [SKSpriteNode: SpaceObject] = [:]
    
    var copyObject: SpawnRate?
    var copyObject2: SpaceObject?
    var timer: Timer?
    var area: Area!
    
    var objSpeedRange: (CGFloat, CGFloat)!
    var objDirRange: (CGFloat, CGFloat)!
    
    
    init(obj: SpawnRate) {
        copyObject = obj
        
        let sprite = SKSpriteNode(color: .red, size: CGSize(width: 300, height: 300))
        
        super.init(0, sprite, (300,500), (300,500), Inventory(), 0, 0, 0, CollisionCategories.EFFECT_FIELD_CATEGORY, CollisionCategories.EFFECT_FIELD_CATEGORY, 0)
        sprite.color = sprite.color.withAlphaComponent(0.5)

    }
    
    required init(instance: SpaceObject) {
        guard let _ = instance as? Spawner else {fatalError("trying to copy something that isn't a spawner")}
        
        super.init(0, instance.sprite, instance.xRange, instance.yRange, instance.inventory, instance.speed, instance.rotation, instance.targetAngle, instance.collisionCategory, instance.testCategory, instance.boostSpeed)
        
    }
    
    override func spawn(at spawnPoint: CGPoint) {
        sprite.position = spawnPoint
        startSpawnTimer()
    }
    
    
    @objc func spawnObject() {
        if let instance = copyObject2?.copy() {
            let spawnPoint = getRandSpawnPosition()
            
            instance.speed = CGFloat.random(in: objSpeedRange.0...objSpeedRange.1)
            instance.targetAngle = CGFloat.random(in: objDirRange.0...objDirRange.1)
            instance.spawn(at: spawnPoint)
            
            spawnedObjects[instance.sprite] = instance
            area.addObject(obj: instance)
            
    
        }
    }
    
    func act(on obj: SpaceObject) {
        
    }
    
    func startSpawnTimer() {
        if let rate = copyObject {
            timer = Timer.scheduledTimer(timeInterval: rate.rate,
            target: self,
            selector: #selector(spawnObject),
            userInfo: nil,
            repeats: true)
            
            area.timers["\(copyObject?.obj.sprite.name! ?? "unnamed")spawner\(OBJECT_ID)"] = timer
        }
    }
    
    override func update(by delta: CGFloat) {
        for sprite in spawnedObjects.keys {
            if sprite.parent != nil {
                
                act(on: spawnedObjects[sprite]!)
                
            } else {
                spawnedObjects.removeValue(forKey: sprite)
            }
        }
    }
    
    func getRandSpawnPosition() -> CGPoint {
        var stop = false
        var p: CGPoint = CGPoint(x: sprite.position.x, y: sprite.position.y)
        while !stop {
            let x = sprite.position.x + CGFloat.random(in: 0...0.5) * sprite.size.width
            let y = sprite.position.y + CGFloat.random(in: 0...0.5) * sprite.size.height

            p = CGPoint(x: x, y: y)// randomPoint
            
            stop = sprite.contains(p)
        }
        
        return p
    }
}



func getAsteroidWallSpawner() -> Spawner {
    let radInv = Inventory([.Nuclear: 50], [.Nuclear: 10])

    let radAst = Asteroid(1, SKSpriteNode(imageNamed: "asteroid_radioactive"), (400, 600), (400, 600), radInv)

    let s = Spawner(obj: SpawnRate(obj: radAst, rate: 0.2, maxNum:
        100))
    s.copyObject2 = radAst
    s.objSpeedRange = (200,2200)
    s.objDirRange = (CGFloat(Double.pi * 1.0/3.0), CGFloat(Double.pi * 2.0 / 3.0))
    
    return s
}
