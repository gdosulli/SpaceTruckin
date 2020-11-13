//
//  GameViewController.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 10/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenWidth: CGFloat = UIScreen.main.bounds.width * UIScreen.main.scale
        var screenHeight: CGFloat = UIScreen.main.bounds.height * UIScreen.main.scale
        
        // force into landscapeRight orentation if in portrait mode
        
        if screenWidth < screenHeight{
            let orentationValue = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(orentationValue, forKey: "orientation")
            // reset screen bounds
            screenWidth = UIScreen.main.bounds.width * UIScreen.main.scale
            screenHeight = UIScreen.main.bounds.height * UIScreen.main.scale
        }
        
        
        
        
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                
                
                scene.size = CGSize(width: screenWidth, height: screenHeight)
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
