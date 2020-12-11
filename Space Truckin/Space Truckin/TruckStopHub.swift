//
//  TruckStopHub.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 12/11/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import UIKit

class TruckStopHubViewController: UIViewController {
    
    var head: TruckPiece!
    
    @IBAction func closeMenu(_ sender: Any) {
        // save state
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let garage = segue.destination as? SpaceStationMenuView {
            garage.playerTruckHead = head
        }
    }
}
