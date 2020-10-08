//
//  TruckScene.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//
import SpriteKit
import GameplayKit


struct truckPiece {
    var target: CGFloat
    
}


class TruckScene: SKScene {
    var head: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        head = SKSpriteNode(imageNamed: "space_truck_cab")
        head.position = CGPoint(x:0,y:0)
        head.zPosition = 1
        self.addChild(head)
        print("Did move")
    }
}
