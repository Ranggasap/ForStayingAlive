//
//  SoundManager.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 17/06/24.
//

import Foundation
import AVFoundation

class SoundManager{
    static let shared = SoundManager()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {}
    
    func playSound(_ sound: Sound, withIdentifier identifier: String){
        guard let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileType) else {
            print("Sound not found")
            return
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
            audioPlayers[identifier] = audioPlayer
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound(withIdentifier identifier: String) {
        audioPlayers[identifier]?.stop()
        audioPlayers[identifier] = nil
    }
    
    func changeSound(to newSound: Sound, withIdentifier identifier: String){
        stopSound(withIdentifier: identifier)
        playSound(newSound, withIdentifier: identifier)
    }
    
    func setVolume(for identifier: String, volume: Float) {
        audioPlayers[identifier]?.volume = volume
    }
}

