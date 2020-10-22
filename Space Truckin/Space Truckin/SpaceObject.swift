//
//  SpaceObject.swift
//  Space Truckin
//
//  Created on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit

class SpaceObject {
    var durability: Int
    var sprite: SKSpriteNode!
    var xRange: (CGFloat, CGFloat)
    var yRange: (CGFloat, CGFloat)
    var inventory: Inventory
    
    init (_ durability: Int,
          _ sprite: SKSpriteNode,
          _ xRange: (CGFloat, CGFloat),
          _ yRange: (CGFloat, CGFloat),
          _ inventory: Inventory) {
        self.durability = durability
        self.sprite = sprite
        self.xRange = xRange
        self.yRange = yRange
        self.inventory = inventory
    }
    
    func spawn() {
        fatalError("Subclasses need to implement the `spawn()` method.")
    }
    
    func onDestroy() {
        fatalError("Subclasses need to implement the `onDestroy()` method.")
    }
}
