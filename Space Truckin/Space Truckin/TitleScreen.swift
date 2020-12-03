//
//  TitleScreen.swift
//  Space Truckin
//
//  Created by Megan Doyle on 12/2/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//
import UIKit

class TitleScreenViewController: UIViewController {
    
      
      override func viewDidLoad() {
          super.viewDidLoad()

        var buttonNum = 0
        var buttonOffset = 70
        var buttonStartY = 100
        var buttonStartX = 500
        
        for i in self.view.subviews {
            if let button = i as? UIButton {
                button.frame = CGRect(x: buttonStartY+(buttonNum * buttonOffset), y: buttonStartX, width: 300, height: 60)
                
                buttonNum += 1
            }
        }
          
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)

      }
      
      
}
