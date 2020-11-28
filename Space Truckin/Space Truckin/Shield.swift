//
//  Shield.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/24/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import SpriteKit

class Shield {
    // Shield is going to be attached to another spaceobject, which will be its Anchor
   
    // it will have fields energy and maxEnergy, which can be used to make an interfaceBar
    
    // The shield size is deterimined by the size of the anchor object
    
    // protect(from: SpaceObject) will be called from the anchor's onImpact function, and returns a bool indicating whether or not the protection was sucessful
    // if the protection was successful, protect can also (but doesn't have to) act on the SpaceObject that collides with the shield
}
