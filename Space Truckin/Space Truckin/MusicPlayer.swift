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
enum Setting {case TITLE_SCREEN, SPACE, STATION, CREDITS}

struct Song {
    let filename: String
    let moods: [Mood]
    let settings: [Setting]
}


class MusicPlayer {
    var mood: Mood?
    var setting: Setting
    var song: AVAudioPlayer?
    var looping: Bool = false
    var currentSong: String?
    var volume: Float = 0.5
    
    let  songs: [Song] = [
                         Song(filename: "dark_space", moods: [Mood.CALM, Mood.DARK], settings: [Setting.SPACE, Setting.STATION]),
                         Song(filename: "tension", moods: [Mood.DARK], settings: [Setting.STATION]),
                         Song(filename: "fall", moods: [Mood.BRIGHT, Mood.CALM], settings: [Setting.SPACE]),
                         Song(filename: "space_mall", moods: [Mood.CALM, Mood.BRIGHT], settings: [Setting.STATION]),
                         Song(filename: "bright song", moods: [Mood.CALM, Mood.BRIGHT], settings: [Setting.CREDITS]),
                         Song(filename: "vibing",moods: [Mood.CALM, Mood.BRIGHT], settings: [Setting.SPACE, Setting.STATION])
 ]
    
    
    
    convenience init() {
        self.init(Mood.DARK)
    }
    
    convenience init(_ m: Mood?) {
        self.init(mood: m, song: nil, looping: false)
    }
    
    init(mood m: Mood?, song s: String?, looping l: Bool) {
        mood = m
        currentSong = s
        looping = l
        setting = Setting.SPACE
        
        if currentSong == nil {
            newSong()
        } else {
            playSong()
        }
    }
    
    func newSong() {
        // find a song in the current mood
        var possibleSongs :[String] = []
        for s in songs {
            if let m = mood {
                if s.moods.contains(m) && s.settings.contains(setting) {
                    possibleSongs.append(s.filename)
                }
            } else if s.settings.contains(setting) {
                possibleSongs.append(s.filename)
            }
        }
        if possibleSongs.count > 1 {
            var newSong = possibleSongs[Int.random(in: 0..<possibleSongs.count)]
            while newSong == currentSong {
                newSong = possibleSongs[Int.random(in: 0..<possibleSongs.count)]
            }
            currentSong = newSong
            playSong()
        } else if possibleSongs.count > 0 {
            currentSong = possibleSongs[0]
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
                song?.setVolume(0, fadeDuration: 0)
                song?.setVolume(volume, fadeDuration: 3)

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
