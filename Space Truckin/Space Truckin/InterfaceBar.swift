//
//  UIBar.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/14/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import SpriteKit

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
        emptyBar.size.width = maxWidth
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
        fullBar.size.width = maxWidth * percentage
        // color gradient stuff
    }
    
    func getChildren() -> [SKNode] {
        return [emptyBar, fullBar]
    }
}

func createStorageBar(size: CGSize) -> InterfaceBar {
    let color1 = UIColor.green
    let color2 = UIColor.red
    let sprite1 = SKSpriteNode(color: UIColor.white, size: size)
    let sprite2 = SKSpriteNode(color: color1, size: size)
    
    return InterfaceBar(emptyBar: sprite1, fullBar: sprite2, colors: (color1, color2), maxWidth: size.width, height: size.height)
}



