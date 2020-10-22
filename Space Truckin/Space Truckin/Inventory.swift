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
extension Item{

}

class Inventory {
    var maxCapacity : Int
    var remainingCapacity : Int
    var usedSpace : Int
    var items : [Item]
    
    init() {
        maxCapacity = 100
        usedSpace = 0
        remainingCapacity = maxCapacity - usedSpace
        items = []
    }
    
    init(_ maxCap: Int, _ used: Int) {
        maxCapacity = maxCap
        usedSpace = used
        remainingCapacity = maxCapacity - usedSpace
        items = []
    }
    
    func getRemainingCapacity() -> Int {
        self.remainingCapacity = maxCapacity - usedSpace
        return remainingCapacity
    }
}

let NO_INVENTORY = Inventory(0,0)
