//
//  Area.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/20/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

struct SpawnRate {
    var obj: SpaceObject?
    var rate: CGFloat
    
    mutating func normalizeRate(total: CGFloat) {
        rate = rate / total
    }
    
}

class Area {
    var scene: SKScene?
    
    var spawnRates: [SpawnRate]!
    var initialItems: [SpaceObject]?
    var uniqueItems: [SpaceObject]!
    var timer = Timer()
    var spawnSpeed: CGFloat = 1.5
    
    var landmark: SpaceObject?
    
    var backgroundItems = [SKNode]()
    
    var objectsInArea: [SKSpriteNode? : SpaceObject] = [:]
    
    // player object
    
    init(scene gameScene: SKScene) {
        scene = gameScene
    }
    
    func loadArea() {
        // just in case this failed to happen on unload
        scene?.removeAllChildren()
        // add background in
        
        // spawn initial objects
        
        // start spawn timers
        
        // reintroduce player
    }
    
    func playerWarp() {
        // spawn the head, add it to the area
        // start a timer that spawns in each successive truck piece (after a short delay)
    }
    
    @objc func warpPiece() {
        // gets the first piece in the followers array that doesn't have a target
        // add that piece to the area
        // set that piece's target to head.getLastPiece() (the last piece in the connected chain)
    }
    
    func addObject(obj: SpaceObject) {
        // add object to objectsInArea
        // add object to scene
    }
    
    @objc func spawnObject() {
        
    }
    
    func unloadArea() {
        // store objects to be shown on return in initial objects
        
        // clear all objects from scene
        
        // store lost truck pieces in uniqueItems
        // remove lost truck pieces from player array
        
    }
    

    
    func update() {
        
    }
    
    
    
    
}
