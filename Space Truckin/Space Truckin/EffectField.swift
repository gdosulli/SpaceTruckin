//
//  EffectField.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/25/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import GameplayKit

class EffectField: SpaceObject {
    // This is going to be a freestanding field that affects objects that enter it, and stops affecting objects that leave it
    
    var objectsInField: [SKSpriteNode: SpaceObject] = [:]
    
    init(sprite: SKSpriteNode, xRange: (CGFloat, CGFloat), yRange: (CGFloat, CGFloat), hideSprite: Bool) {
        
        super.init(0, sprite, xRange, yRange, Inventory(), 0, 0, 0, 0)
        
        sprite.isHidden = hideSprite
    }
    
    required init(instance: SpaceObject) {
        guard let _ = instance as? EffectField else {fatalError()}
        
        super.init(instance.durability, instance.sprite, instance.xRange, instance.yRange, instance.inventory, instance.speed, instance.rotation, instance.targetAngle, instance.boostSpeed)
        
    }
    
}
