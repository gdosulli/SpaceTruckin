//
//  MusicPlayer.swift
//  Space Truckin
//
//  Created by Ethan Nerney on 11/5/20.
//  Copyright © 2020 SpaceTruckin. All rights reserved.
//

import Foundation
import AVFoundation

enum Mood {case DARK, BRIGHT, CALM, INTERRUPTION, PRESENT}
enum Setting {case TITLE_SCREEN, SPACE, STATION, JUMP, CREDITS, ALL}

class Song {
    let filename: String
    let moods: [Mood]
    let settings: [Setting]
    let relativeVolume: Float
    var loop = false
    
    var nextSong: Song?
    
    
    // copy constructor
    convenience init(copy: Song) {
        self.init(filename: copy.filename, moods: copy.moods, settings: copy.settings, volume: copy.relativeVolume)
    }
    
    // everything but volume (default: 0.5)
    convenience init(filename: String, moods: [Mood], settings: [Setting]) {
        self.init(filename: filename, moods: moods, settings: settings, volume: 0.5)
    }
    
    // full constructor
    init (filename: String, moods: [Mood], settings: [Setting], volume: Float) {
        self.filename = filename
        self.moods = moods
        self.settings = settings
        self.relativeVolume = volume
    }
    
    func getNext() -> Song{
        if nextSong == nil || loop {
            return self
        } else {
            return nextSong!
        }
    }
    
    
}
extension Song: Equatable {
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.filename == rhs.filename
    }
}

//\///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

struct MySongs {
    static let DARK_SPACE = Song(filename: "dark_space", moods: [Mood.CALM, Mood.DARK, Mood.PRESENT], settings: [Setting.SPACE, Setting.STATION, Setting.ALL], volume: 0.5)
    static let TENSION = Song(filename: "tension", moods: [Mood.DARK, Mood.PRESENT], settings: [Setting.STATION, Setting.ALL], volume: 0.3)
    static let FALL = Song(filename: "fall", moods: [Mood.BRIGHT, Mood.CALM], settings: [Setting.SPACE, Setting.ALL], volume: 0.2)
    static let SPACE_MALL = Song(filename: "space_mall", moods: [Mood.CALM, Mood.BRIGHT, Mood.PRESENT], settings: [Setting.STATION, Setting.ALL], volume: 0.2)
    static let BRIGHT_SONG = Song(filename: "bright song", moods: [Mood.CALM, Mood.BRIGHT], settings: [Setting.CREDITS, Setting.ALL], volume: 0.4)
    static let VIBING = Song(filename: "vibing",moods: [Mood.CALM, Mood.BRIGHT], settings: [Setting.STATION, Setting.ALL], volume: 0.3)
    static let SPACEJAZZ = Song(filename: "spacejazz", moods: [Mood.CALM, Mood.PRESENT], settings: [Setting.SPACE, Setting.ALL])
    static let JUMP = Song(filename: "warp sound", moods: [Mood.DARK], settings: [Setting.JUMP], volume: 0.5)
    
    // interruptions
    static let INTERRUPT1 = Song(filename: "interrupt1", moods: [Mood.INTERRUPTION, Mood.DARK], settings: [Setting.ALL], volume: 0.4)
    static let INTERRUPT2 = Song(filename: "interrupt2", moods: [Mood.INTERRUPTION, Mood.DARK], settings: [Setting.ALL], volume: 0.4)
    
        
    static let  ALL_SONGS = [DARK_SPACE,TENSION,SPACE_MALL, SPACEJAZZ]//,FALL,BRIGHT_SONG,VIBING,,INTERRUPT1,INTERRUPT2]
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class MusicPlayer {
    var mood: Mood?
    var setting: Setting
    var song: AVAudioPlayer?
    var currentSong: Song?
    var currentPlaylist: [Song] = []
    var globalVolume: Float = 2.0
    var muted = true

    
    
    convenience init() {
        self.init(Mood.DARK)
    }
    
    convenience init(_ m: Mood?) {
        self.init(mood: m, setting: Setting.SPACE)
    }
    
    
    init(mood m: Mood?, setting s: Setting) {
        mood = m
        setting = s
        
        getPlaylist()
        
        if currentPlaylist != [] {
            playSong()
        }
        
    }
    
    func getPlaylist() {
        var tempSongList: [Song] = []
        // get songs in the current setting and with the current mood (if applicable)
        for s in MySongs.ALL_SONGS {
            if !s.moods.contains(Mood.INTERRUPTION) {
                if let m = mood {
                    if s.moods.contains(m) && s.settings.contains(setting){
                        tempSongList.append(Song.init(copy: s))
                    }
                } else if s.settings.contains(setting) {
                    tempSongList.append(Song.init(copy: s))
                }
            }
        }
        
        // shuffle the list and connect the songs before assigning to the class field
        tempSongList.shuffle()
        for i in 0..<tempSongList.count {
            if i == tempSongList.count-1 {
                tempSongList[i].nextSong = tempSongList[0]
            } else {
                tempSongList[i].nextSong = tempSongList[i+1]
            }
        }
        currentPlaylist = tempSongList
        
        if currentPlaylist != [] {
            currentSong = currentPlaylist[0]
        }
        
    }
    
    func skip() {
        currentSong = currentSong!.nextSong
        playSong()
    }
 
    
    func interrupt(withMood m: Mood) {
        
        mood = m
        getPlaylist()
        
        var interruptions: [Song] = []
        for s in MySongs.ALL_SONGS {
            if s.moods.contains(Mood.INTERRUPTION) {
                interruptions.append(Song(copy: s))
            }
        }
        
        if let interruption = interruptions.randomElement() {
            interruption.nextSong = currentSong
            currentSong = interruption
        }
        
        playSong()
    }
    
    func playSong() {
        let file = currentSong?.filename
        guard let url = Bundle.main.url(forResource:file, withExtension: "m4a") else { print("failed"); return }
               do {
                   print("\(file!)")
                      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                      try AVAudioSession.sharedInstance().setActive(true)

                      /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                      song = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
                    song?.setVolume(0, fadeDuration: 0) 
                    if !muted {
                            song?.setVolume(globalVolume * currentSong!.relativeVolume, fadeDuration: 3)
                    }
                          /* iOS 10 and earlier require the following line:
                      player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

                      guard let song = song else { return }

                   print("play")
                      song.play()

                  } catch let error {
                      print(error.localizedDescription)
                  }
    }
    
    func mute() {
        song?.setVolume(0, fadeDuration: 0.2)
    }
    
    func unmute() {
        song?.setVolume(globalVolume * currentSong!.relativeVolume, fadeDuration: 1)
    }

    
    func update() {
        // if the current playlist exists
        if currentPlaylist != [] {
            if !song!.isPlaying {
                currentSong = currentSong?.getNext()
                playSong()
            }
            
        }
    }
    
    func playSong(_ song: Song) {
        currentSong = song
        playSong()
    }
    
    func setLooping(loop: Bool) {
        currentSong?.loop = loop
    }
}
