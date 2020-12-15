//
//  Missile.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 12/14/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import GameplayKit

struct StatusEffect  {
    var update: (CGFloat) -> Void
}

class Missile: SpaceObject {
    var effects = [StatusEffect]()
    var target: SpaceObject?
    
    init() {
        // idea: missile gets boosted after first impact, and explodes on the second
        super.init(1, SKSpriteNode(imageNamed: "rad_missile"), (1,1), (1,1), Inventory(), 450, 0, CGFloat(Double.pi / 2), 600)
        knockback = 20
        impactDamage = 10
    }
    
    required init(instance: SpaceObject) {
        fatalError("init(instance:) has not been implemented")
    }
    
    
    override func onImpact(with obj: SpaceObject, _ contact: SKPhysicsContact) {
        if !boosted {
            boosted = true
            knockback *= 1.5
        } else {
            onDestroy()
        }
    }
    
    
    func moveTo(_ target: SpaceObject, by delta: CGFloat) {
        changeAngleTo(point: target.sprite.position)
        moveUnguided(by: <#T##CGFloat#>)
    }
    
    func moveUnguided(by delta: CGFloat) {
        var deltaMod = delta
        var turnMod = CGFloat(60)
        
        move(by: deltaMod)
        turn(by: deltaMod * turnMod)
        
    }
    
    override func update(by delta: CGFloat) {
        
        
        // move code
        if let missileTarget = target {
            moveTo(missileTarget, by: delta)
        } else {
            moveUnguided(by: delta)
        }
    }
    
    override func onDestroy() {
        let duration = Double.random(in: 0.4...0.7)
        let removeDate = Date().addingTimeInterval(duration)
        let timer = Timer(fireAt: removeDate, interval: 0, target: self, selector: #selector(deleteSelf), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
    }

    @objc func deleteSelf () {
        
        for s in getChildren() {
            s?.removeFromParent()
        }
    }

}

