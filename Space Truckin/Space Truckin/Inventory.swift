//
//  Inventory.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit

enum ItemType : Int, CaseIterable {
        case Scrap,
         Nuclear,
         Precious,
         Water,
         Oxygen,
         Stone
         //Currency
}

struct Item {
    var type: ItemType
    var value: Int
}
extension Item {

}

class Inventory {
    var maxCapacities : [ItemType:Int]
    var items : [ItemType:Int]
    
    init() {
        maxCapacities = [ItemType:Int]()
        items = [ItemType:Int]()
        
        for type in ItemType.allCases {
            maxCapacities[type] = 100
            items[type] = 0
        }
    }
    
    init(_ maxCapacities: [ItemType:Int], _ items: [ItemType:Int]) {
        self.maxCapacities = maxCapacities
        self.items = items
    }
    
    func getRemainingCapacity(for type: ItemType) -> Int {
        return maxCapacities[type]! - items[type]!
    }
    
    func addItem(item: Item) -> Bool {
        let remainingCapacity = maxCapacities[item.type]! - items[item.type]!
        if item.value > remainingCapacity {
            return false
        }
        
        items[item.type] = items[item.type]! + item.value
        return true
    }
    
    func remove(from type: ItemType, quantity: Int) -> Item? {
        if items[type]! >= quantity {
            let removedItem = Item(type: type, value: quantity)
            items[type]! = items[type]! - quantity
            
            return removedItem
        }
        
        return nil
    }

    func getAll() -> [ItemType:Int] {
        return items
    }
}

struct SelectedInventory {
    var inventory: Inventory
    var capsule: SKSpriteNode
    var invTypes: [ItemType:SKSpriteNode]
    var invLabels: [ItemType:SKLabelNode]
    var baseOpacity: CGFloat
    var fadeInterval: TimeInterval
    var fadeTime: TimeInterval
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    
    var lastFade: TimeInterval = 0
    var capsuleClicked = false
    var faded = false
    
    mutating func update(_ currentTime: TimeInterval) {
        refreshLabels()
        
        if capsuleClicked {
            capsuleClicked = false
            lastFade = currentTime
        } else if currentTime - lastFade >= fadeInterval && !faded {
            fadeOpacity()
            lastFade = currentTime
        }
    }
    
    func move(to position: CGPoint) {
        var pos = position
        
        capsule.position = position
        pos.y = pos.y - frameHeight / 8
        for type in ItemType.allCases {
            invTypes[type]?.position = pos
            invLabels[type]?.position.x = pos.x + frameWidth / 15
            invLabels[type]?.position.y = pos.y - invLabels[type]!.fontSize
            
            pos.y = pos.y - frameHeight / 7
            invTypes[type]?.
        }
    }
    
    func refreshLabels() {
        for type in ItemType.allCases {
            invLabels[type]?.text = "\(String(describing: inventory.items[type]!)) / \(String(describing: inventory.maxCapacities[type]!))"
        }
    }
    
    mutating func fadeOpacity() {
        let fadeAction = SKAction.fadeAlpha(to: baseOpacity, duration: fadeTime)
        capsule.run(fadeAction)
        for type in ItemType.allCases {
            invTypes[type]?.run(fadeAction)
            invLabels[type]?.run(fadeAction)
        }
        faded = true
    }
    
    mutating func resetOpacity() {
        capsule.alpha = 1
        for type in ItemType.allCases {
            invTypes[type]?.alpha = 1
            invLabels[type]?.alpha = 1
        }
        capsuleClicked = true
        faded = false
    }
}

let NO_INVENTORY = Inventory()
