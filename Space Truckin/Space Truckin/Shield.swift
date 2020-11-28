//
//  Shield.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/24/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

class Shield {
    // Shield is a component of one or more spaceObjects
    // all spaceObjects with the same 
   
    // it will have fields energy and maxEnergy, which can be used to make an interfaceBar
    
    // The shield size is deterimined by the size of the anchor object
    
    // protect(_ shielded: SpaceObject, from obj: SpaceObject) will be called from the anchor's onImpact function, and returns a bool indicating whether or not the protection was sucessful
    // if the protection was successful, protect can also (but doesn't have to) act on the SpaceObject that collides with the shield
    var energy: CGFloat
    var maxEnergy: CGFloat
    
    init(maximumEnergy: CGFloat) {
        maxEnergy = maximumEnergy
        energy = maxEnergy
    }
    
    func protect(_ shielded: SpaceObject, from obj: SpaceObject) -> Bool {
        let impactDamage = obj.getImpactDamage()
        let difference = energy - impactDamage
        
        if difference <= 0 {
            energy = 0
            return false
        } else {
            energy = difference
            return true
        }
    }
    
    
    // spaceObjects could have a showShield() function that would add a shield texture on top of the current sprite, and start a timer to remove it shortly after
    
}
