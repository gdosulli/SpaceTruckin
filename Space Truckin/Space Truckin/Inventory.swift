//
//  Inventory.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/22/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation

enum ItemType {case Scrap, Nuclear, Precious, Water, Currency}
struct Item {
    var type: ItemType
    var value: Int
    
}

class Inventory {
    var maxCapacity : Int
    var remainingCapacity : Int
    var usedSpace : Int
    var items : [Item]
    
    init() {
        maxCapacity = 100
        usedSpace = 0
        _ = getRemainingCapacity()
    }
    
    func getRemainingCapacity() -> Int {
        self.remainingCapacity = maxCapacity - usedSpace
        return remainingCapacity
    }
}
