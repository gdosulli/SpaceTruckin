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
    
    
    
    func getPercentFull(for type: ItemType) -> CGFloat {
        if maxCapacities[type]! != 0 {
            return CGFloat(items[type]!) / CGFloat(maxCapacities[type]!)
        }
        
        return 0
    }

    func getAll() -> [ItemType:Int] {
        return items
    }
}

struct SelectedInventory {
    var inventory: Inventory
    var capsule: SKSpriteNode
    var invTypes: [ItemType:SKSpriteNode]
    var invBars: [ItemType:InterfaceBar]
    var baseOpacity: CGFloat
    var fadeInterval: TimeInterval
    var fadeTime: TimeInterval
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    
    var lastFade: TimeInterval = 0
    var capsuleClicked = false
    var faded = false
    
    mutating func update(_ currentTime: TimeInterval) {
        refreshBars()
        
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
            invBars[type]?.move(to: CGPoint(x: pos.x + invTypes[type]!.size.width/1.5,
                                            y: pos.y - invTypes[type]!.size.height/2))
            
            pos.y = pos.y - frameHeight / 8
        }
    }
    
    func refreshBars() {
        for type in ItemType.allCases {
            invBars[type]?.updatePercentage(p: inventory.getPercentFull(for: type))
            invBars[type]?.update()
            if (inventory.items[type]! > 0) {
                //print("\(type) percent full: \(invBars[type]!.percentage)%")
            }
        }
    }
    
    mutating func fadeOpacity() {
        let fadeAction = SKAction.fadeAlpha(to: baseOpacity, duration: fadeTime)
        capsule.run(fadeAction)
        for type in ItemType.allCases {
            invTypes[type]?.run(fadeAction)
            for child in invBars[type]!.getChildren() {
                child.run(fadeAction)
            }
        }
        faded = true
    }
    
    mutating func resetOpacity() {
        capsule.alpha = 1
        for type in ItemType.allCases {
            invTypes[type]?.alpha = 1
            for child in invBars[type]!.getChildren() {
                child.alpha = 1
            }
        }
        capsuleClicked = true
        faded = false
    }
}

let NO_INVENTORY = Inventory()
