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
    var looping: Bool = false
    var currentSong: String?
    
    let songs: [String: Mood] = ["fall": Mood.BRIGHT, "tension": Mood.DARK, "dark_space": Mood.DARK]
    convenience init() {
        self.init(Mood.DARK)
    }
    
    convenience init(_ m: Mood) {
        self.init(mood: m, song: nil, looping: false)
    }
    
    init(mood m: Mood, song s: String?, looping l: Bool) {
        mood = m
        currentSong = s
        looping = l
        
        if currentSong == nil {
            newSong()
        } else {
            playSong()
        }
    }
    
    func newSong() {
        // find a song in the current mood
        var songsWithMood :[String] = []
        for s in songs.keys {
            if mood == songs[s] {
                songsWithMood.append(s)
            }
        }
        if songsWithMood.count > 1 {
            currentSong = songsWithMood[Int.random(in: 0..<songsWithMood.count)]
            playSong()
        } else if currentSong != nil {
            playSong()
        }
        
        // set it to play
        
    }
    
    func playSong() {
        let file = currentSong
        guard let url = Bundle.main.url(forResource:file, withExtension: "m4a") else { print("failed"); return }
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

    func playTest() {
        print("called")
        let file = "tension"
        print("file")
        guard let url = Bundle.main.url(forResource:file, withExtension: "m4a") else { print("failed"); return }
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
    
    func update() {
        if !(song?.isPlaying ?? false) {
            if looping {
                playSong()
            } else {
                newSong()
            }
        }
    }
}
