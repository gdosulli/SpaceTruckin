//
//  Inventory.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation

enum ItemType : CaseIterable {
    case Scrap,
         Nuclear,
         Precious,
         Water,
         Currency
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

let NO_INVENTORY = Inventory()
