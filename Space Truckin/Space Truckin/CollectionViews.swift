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
    
    @IBOutlet var healthLabel: UILabel!
    @IBOutlet var healingPriceLabel: UILabel!
    
    
    static let itemFiles: [ItemType: String] = [ItemType.Scrap: "Inventory_ScrapMetal", .Nuclear: "Inventory_radioactiveMaterial",  .Precious: "Inventory_PreciousMetal", .Water:
        "Inventory_water", .Oxygen:
        "Inventory_Oxygen",.Stone:
        "Inventory_Stone" ]

    var piece: TruckPiece!
    
    func setText() {
        pieceNameLabel.text = piece.sprite.name
        healthLabel.text = "\(piece.durability)/\(piece.maxDurability) HP"
    }
    
    func setImages() {
        let image: UIImage = UIImage(cgImage: (piece.sprite.texture?.cgImage())!)
        pieceImage.image = image
        
        let item = piece.inventory.getAll().max(by: {i1, i2 in
            return i1.value > i2.value
        })
        
        let iconImage = UIImage(named: TruckPieceCollectionCell.itemFiles[item!.key]!)
        inventoryItemImage.image = iconImage
    }
    
}

class TruckCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var truckHead: TruckPiece!

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return truckHead.getAllPieces().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let piece = truckHead.getAllPieces()[truckHead.getAllPieces().count - indexPath.row]
        
        let cell = dequeueReusableCell(withReuseIdentifier: "TruckCell", for: indexPath) as! TruckPieceCollectionCell
        
        cell.piece = piece
        cell.setText()
        cell.setImages()
        
        return cell
        
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