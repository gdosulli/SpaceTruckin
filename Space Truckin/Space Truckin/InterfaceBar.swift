//
//  UIBar.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/14/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit


extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
    
    func toColor(color c: UIColor, percentage p: CGFloat) -> UIColor {
        let rgba1 = self.rgba
        let rgba2 = c.rgba

        let dr = rgba2.red - rgba1.red
        let dg = rgba2.green - rgba1.green
        let db = rgba2.blue - rgba1.blue

        return UIColor(displayP3Red: rgba1.red + dr * p, green: rgba1.green + dg * p, blue: rgba1.blue + db * p, alpha: rgba1.alpha)
        
    }
}

class InterfaceBar {
    var emptyBar: SKSpriteNode
    var fullBar: SKSpriteNode
    var colors: (UIColor, UIColor)
    var percentage: CGFloat
    var maxWidth: CGFloat
    var height: CGFloat
    var leftAligned = true
    
    init(emptyBar e: SKSpriteNode, fullBar f: SKSpriteNode, colors c: (UIColor, UIColor), maxWidth m: CGFloat, height h: CGFloat) {
        emptyBar = e
        fullBar = f
        colors = c
        percentage = 0
        maxWidth = m
        emptyBar.size.width = CGFloat(Int(maxWidth))
        fullBar.size.width = 0
        height = h
        emptyBar.size.height = height
        fullBar.size.height = height
        
    }
    
    
    func updatePercentage(p: CGFloat) {
        if p > 1 {
            percentage = 1.0
        } else if p < 0 {
            percentage = 0
        } else {
            percentage = p
        }
    }
       
    func move(to pos: CGPoint) {
        emptyBar.position = pos
        if leftAligned {
            fullBar.position.x = pos.x - maxWidth/2 + fullBar.size.width / 2
            fullBar.position.y = pos.y
        } else {
            fullBar.position = pos
        }
    }
    
    func update() {
        var currWidth = fullBar.size.width
        let newWidth = CGFloat(Int(maxWidth * percentage))
        if currWidth < newWidth {
            currWidth += 3 //Changes bar raising speed
        } else if currWidth > newWidth {
            currWidth -= 2 //Changes bar lowering speed
        }
        fullBar.size.width = currWidth

        // color gradient stuff
        fullBar.color = colors.0.toColor(color: colors.1, percentage: percentage)
    }
    
    func getChildren() -> [SKNode] {
        return [emptyBar, fullBar]
    }
}

func createStorageBar(size: CGSize) -> InterfaceBar {
    let color2 = UIColor.red
    let color1 = UIColor.green.toColor(color: color2, percentage: -0.2)

    let sprite1 = SKSpriteNode(color: UIColor.white, size: size)
    let sprite2 = SKSpriteNode(color: color1, size: size)
    
    return InterfaceBar(emptyBar: sprite1, fullBar: sprite2, colors: (color1, color2), maxWidth: size.width, height: size.height)
}

func createFuelBar(size: CGSize) -> InterfaceBar {
    let color2 = UIColor.green
    let color1 = UIColor.red.toColor(color: color2, percentage: -0.2)

    let sprite1 = SKSpriteNode(color: UIColor.white, size: size)
    let sprite2 = SKSpriteNode(color: color1, size: size)
    
    return InterfaceBar(emptyBar: sprite1, fullBar: sprite2, colors: (color1, color2), maxWidth: size.width, height: size.height)
}



