//
//  UpgradeMenu.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 12/11/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import UIKit

class UpgradeMenuViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource{
    
    
 
    @IBOutlet var pieceCollection: UICollectionView!
    @IBOutlet var numericalUpgradeTable: UITableView!
    
    @IBOutlet var bigPiece: UIImageView!
    
    var currentSelected = CapsuleType.Head
    
    let spriteNames = ["space_truck_cab", "space_truck_capsule1", "space_truck_capsule2", "space_truck_capsule3"]
    
    
    override func viewDidLoad() {
        pieceCollection.delegate = self
        pieceCollection.dataSource = self
        
        numericalUpgradeTable.dataSource = self
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // Collection and Table view protocol stubs
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spriteNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pieceCell", for: indexPath)
        
        if let imageView = cell.viewWithTag(1) as?  UIImageView {
            let image = UIImage(named: spriteNames[currentSelected.rawValue])
            imageView.image = image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "numericalUpgradeCell", for: indexPath)
        
        
        return cell
    }
    
    
}
