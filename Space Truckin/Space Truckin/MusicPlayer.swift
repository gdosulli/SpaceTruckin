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
    
    init() {
        print("init")


    }

    func playTest() {
        print("called")
        guard let url = Bundle.main.url(forResource: "dark_space", withExtension: "m4a") else { print("failed"); return }
        do {
            print("file found")
               try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
               try AVAudioSession.sharedInstance().setActive(true)

               /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
               song = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)

               /* iOS 10 and earlier require the following line:
               player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

               guard let song = song else { return }

            print("play")
               song.play()

           } catch let error {
               print(error.localizedDescription)
           }
    }
}
