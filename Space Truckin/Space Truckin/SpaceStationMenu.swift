import Foundation
import SpriteKit

class SpaceStationScreen {
    let background: SKSpriteNode
    var truckHead: TruckPiece!
    var invLabels: [ItemType:SKLabelNode]
    var frameSize: CGSize = CGSize(width: 1, height: 1)
    
    init() {
        invLabels = [ItemType:SKLabelNode]()
        background = SKSpriteNode(imageNamed: "ComputerFrameXL")
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 100
        background.name = "spaceStationScreen"
        background.isUserInteractionEnabled = false
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.isHidden = true
        let screen = SKSpriteNode(color: UIColor(displayP3Red: 0.3373, green: 0, blue: 0.0039, alpha: 1), size: CGSize(width: frameSize.width/1.1, height: frameSize.height/1.2))
        screen.position = CGPoint(x: 0, y: 0)
        screen.zPosition = 99
        screen.name = background.name
        screen.isUserInteractionEnabled = false
        screen.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        background.addChild(screen)
        
        
        
        var offsetX = background.size.width/3
        var offsetY = background.size.height/5.5
        var col = 0
        for type in ItemType.allCases {
            
            let item = SKSpriteNode(imageNamed: DroppedItem.filenames[type.rawValue])
            item.zPosition = 101
            item.isUserInteractionEnabled = false
            item.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            item.size = CGSize(width: frameSize.width/7, height: frameSize.width/7)
            item.position = CGPoint(x: 0, y: 0)
            item.name = background.name
            
            let slot = SKSpriteNode(imageNamed: "Inventory_slot")
            slot.zPosition = 101
            slot.isUserInteractionEnabled = false
            slot.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            slot.size = CGSize(width: item.size.width, height: item.size.height)
            slot.position = CGPoint(x: 0 - offsetX, y: 0 - offsetY)
            slot.name = background.name
            
            slot.addChild(item)
            
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.zPosition = 102
            label.fontColor = UIColor.white
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
            label.fontSize = background.size.height/16
            label.position = CGPoint(x: 0 - offsetX, y: (0 - offsetY) - slot.size.height/1.8)
            label.name = background.name
            
            //trucks[type] = item
            invLabels[type] = label
            
            offsetX -= background.size.width/3
            col += 1
            
            if col == 3 {
                offsetX = background.size.width/3
                offsetY = 0 - background.size.height/4
            }
            background.addChild(slot)
            background.addChild(label)
        }
    }
    
    func resizeEverything() {
        
    }
    
    func update(_ truck: TruckPiece) {
        self.truckHead = truck
        refreshLabels()
    }
    
    
    func refreshLabels() {
        var piece = truckHead
        while piece != nil {
            // stuff
            
            piece = piece?.followingPiece
        }
    }
    
    func show() {
        background.isHidden = !background.isHidden
    }
}
