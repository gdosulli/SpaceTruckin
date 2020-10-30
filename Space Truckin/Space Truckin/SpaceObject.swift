//
//  SpaceObject.swift
//  Space Truckin
//
//  Created on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SpaceObject : Movable {
    var durability: Int
    var xRange: (CGFloat, CGFloat)
    var yRange: (CGFloat, CGFloat)
    var inventory: Inventory
    
    init (_ durability: Int,
          _ sprite: SKSpriteNode,
          _ xRange: (CGFloat, CGFloat),
          _ yRange: (CGFloat, CGFloat),
          _ inventory: Inventory,
          _ speed: CGFloat,
          _ rotation: CGFloat,
          _ targetAngle: CGFloat) {
        self.durability = durability
        self.xRange = xRange
        self.yRange = yRange
        self.inventory = inventory
        
        super.init(speed: speed,
                   rotation: rotation,
                   angleInRadians: targetAngle,
                   sprite: sprite)
    }
    
    // convenience for non-moving objects
    convenience init (_ durability: Int,
                      _ sprite: SKSpriteNode,
                      _ xRange: (CGFloat, CGFloat),
                      _ yRange: (CGFloat, CGFloat),
                      _ inventory: Inventory) {
        self.init(durability, sprite, xRange, yRange, inventory, 0, 0, 0)
    }
    
    
    func spawn(at spawnPoint: CGPoint) {
        fatalError("Subclasses need to implement the `spawn()` method.")
    }
    
    func onDestroy() {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
    
    func getChildren() -> [SKNode?] {
        return [sprite]
    }
    
    func update() {
        
    }
}
