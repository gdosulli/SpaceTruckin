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
    
    var copyObject: SpaceObject?
    
    func spawnOBject() {
        if let instance = copyObject?.copy() {
        let spawnPoint = getRandSpawnPosition()
    
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
