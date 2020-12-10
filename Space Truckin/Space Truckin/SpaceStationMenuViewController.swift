//
//  SpaceStationMenuViewController.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 12/9/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import UIKit

class SpaceStationMenuView: UIViewController {
    
    @IBOutlet var topView: UICollectionView!
    @IBOutlet var middleView: TruckCollectionView!
    @IBOutlet var bottomView: UICollectionView!
    
    
    // what the space station's selling, and at what price
    var spaceStationGoods = [(Item, Int)]()
    // "" "" buying "" ""
    var spaceStationBuying = [(Item,Int)]()
    
    var playerGarage = [TruckPiece]()
    
    var playerTruckHead: TruckPiece!
    
    override func viewDidLoad() {
        middleView.truckHead = playerTruckHead
        middleView.delegate = middleView
        middleView.dataSource = middleView
    }
    
}
