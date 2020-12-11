//
//  CollectionViews.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 12/10/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import UIKit

class TruckPieceCollectionCell: UICollectionViewCell {
    
    @IBOutlet var pieceImage: UIImageView!
    
    @IBOutlet var infoView: UIView!
    @IBOutlet var pieceNameLabel: UILabel!
    @IBOutlet var inventoryItemImage: UIImageView!
    @IBOutlet var storageBar: UIView!
    
    @IBOutlet var healthLabel: UILabel!
 
    
    
    static let itemFiles: [ItemType: String] = [ItemType.Scrap: "Inventory_ScrapMetal", .Nuclear: "Inventory_radioactiveMaterial",  .Precious: "Inventory_PreciousMetal", .Water:
        "Inventory_water", .Oxygen:
        "Inventory_Oxygen",.Stone:
        "Inventory_Stone" ]

    var piece: TruckPiece!
    
    func setText() {
        print("setting cell text")
        pieceNameLabel.text = piece.sprite.name
        healthLabel.text = "\(piece.durability)/\(piece.maxDurability) HP"
    }
    
    
    // todo: the truck sprite gets set to the wrong one after drill animation finishes
    func setImages() {
        
        if piece.isHead {
            let image = UIImage(named: "space_truck_cab")
    
            pieceImage.image = UIImage(ciImage: CIImage(image: image!)!, scale: 1, orientation: UIImage.Orientation.right)
        } else {
            let image: UIImage = UIImage(cgImage: (piece.sprite.texture?.cgImage())!, scale: 1.0, orientation: UIImage.Orientation.right)
            pieceImage.image = image
        }
        
        if let type = piece.inventory.itemType {
            let iconImage = UIImage(named: TruckPieceCollectionCell.itemFiles[type]!)
            inventoryItemImage.image = iconImage
            let maxWidth = 75
            let p = piece.inventory.items[type]! / piece.inventory.getMaxCapacity(for: type)
            var color: UIColor
            if type == .Oxygen {
                color = UIColor.red.toColor(color: UIColor.green, percentage: CGFloat(p))
            } else {
                color = UIColor.green.toColor(color: UIColor.red, percentage: CGFloat(p))
            }
            storageBar.backgroundColor = color
            storageBar.frame.size.width = CGFloat(maxWidth) * CGFloat(p)
            
        } else {
            let item = piece.inventory.getAll().max(by: {i1, i2 in
                return i1.value > i2.value
            })
            
            let iconImage = UIImage(named: TruckPieceCollectionCell.itemFiles[item!.key]!)
            inventoryItemImage.image = iconImage
        }
        
        // i gotta set the inventory bar here too but I don't want to right now

        
        infoView.isHidden = true
    }
    
}

class TruckCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var truckHead: TruckPiece!

    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Sections")
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("initializing collection view w \(truckHead.getAllPieces().count) pieces")
        return truckHead.getAllPieces().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItemAt")
        let piece = truckHead.getAllPieces().reversed()[indexPath.row]
        
        let cell = dequeueReusableCell(withReuseIdentifier: "TruckCell", for: indexPath) as! TruckPieceCollectionCell
        
        cell.piece = piece
        cell.setText()
        cell.setImages()
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size set")
        return CGSize(width: self.frame.height, height: self.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = (collectionView.cellForItem(at: indexPath) as! TruckPieceCollectionCell)
        cell.infoView.isHidden = !cell.infoView.isHidden
    }
    
    
}

class GarageCollectionView: UICollectionView {
    
}

class ShopCollectionView: UICollectionView {
    
}

class UpgradesCollectionView: UICollectionView {
    
}
