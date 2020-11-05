//
//  MusicPlayer.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import AVFoundation


enum Mood {case DARK, BRIGHT, CALM}

class MusicPlayer {
    var mood: Mood?
    var song: AVAudioPlayer?
    
    

    func playTest() {
        let path = Bundle.main.path(forResource: "dark_space.m4a", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            song = try AVAudioPlayer(contentsOf: url)
            song?.play()
        } catch {
            // couldn't load file :(
        }
    }
}
