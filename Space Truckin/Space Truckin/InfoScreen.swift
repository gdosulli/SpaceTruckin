//
//  InfoScreen.swift
//  Space Truckin
//
//  Created by Gavin  O'Sullivan on 11/27/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit

class InfoScreen {
    let background: SKSpriteNode
    var inventory: Inventory
    var invTypes: [ItemType:SKSpriteNode]
    var invLabels: [ItemType:SKLabelNode]
    
    init(frameSize: CGSize) {
        inventory = Inventory()
        invTypes = [ItemType:SKSpriteNode]()
        invLabels = [ItemType:SKLabelNode]()
        background = SKSpriteNode(imageNamed: "ComputerFrameXL")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 100
        background.name = "sectorMap"
        background.isUserInteractionEnabled = false
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.isHidden = true
        background.size = CGSize(width: frameSize.width, height: frameSize.height)
        
        for type in ItemType.allCases {
            let item = SKSpriteNode(imageNamed: DroppedItem.filenames[type.rawValue])
            item.zPosition = 100
            item.isUserInteractionEnabled = false
            item.anchorPoint = CGPoint(x: 1, y: 1)
            item.size = CGSize(width: frameSize.width/8, height: frameSize.width/8)
            
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.zPosition = 100
            label.fontColor = UIColor.white
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            label.fontSize = 45
            
            invTypes[type] = item
            invLabels[type] = label
        }
    }
    
    func update(_ inventory: Inventory) {
        self.inventory = inventory
        refreshLabels()
    }
    
    
    func refreshLabels() {
        for type in ItemType.allCases {
            invLabels[type]?.text = "\(String(describing: inventory.items[type]!)) / \(String(describing: inventory.maxCapacities[type]!))"
        }
    }
    
    func show() {
        background.isHidden = !background.isHidden
    }
}
