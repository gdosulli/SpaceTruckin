//
//  EffectBubbles.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/17/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

enum EffectType {case SNAP, POP, BOOM}
class EffectBubble: SpaceObject {
    
    var duration: TimeInterval
    
    init(type: EffectType, duration: TimeInterval) {
        var spriteName = ""
        switch  type {
        case .SNAP:
            spriteName = "snap!"
        default:
            spriteName = ""
        }
        self.duration = duration
        super.init(0, SKSpriteNode(imageNamed: spriteName),(50,50),(50,50),NO_INVENTORY,0, 10, 0, CollisionCategories.TRUCK_CATEGORY, CollisionCategories.SPACE_JUNK_CATEGORY, 10.0)
    }
    
    required init(instance: SpaceObject) {
        let effect = instance as! EffectBubble
        self.duration = effect.duration
        
        super.init(instance: instance)
    }
    
    
    override func spawn(at spawnPoint: CGPoint) {
        // set  initial position
        sprite.position = spawnPoint
        
        // setup asteroid to rotate randomly
        let removeDate = Date().addingTimeInterval(duration)
        let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    @objc func deleteSelf() {
        self.sprite.removeFromParent()
    }
}
