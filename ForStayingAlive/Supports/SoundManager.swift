//
//  SoundManager.swift
//  ForStayingAlive
//
//  Created by Gusti Rizky Fajar on 19/06/24.
//

import AVFoundation

class SoundManager : NSObject, AVAudioPlayerDelegate {
	static let sharedInstance = SoundManager()
	
	var audioPlayers: [AVAudioPlayer] = [] // To play more than one sound
	
	public func startPlaying(soundName: String, fileExtension: String) -> AVAudioPlayer? {
		if let soundURL = Bundle.main.url(forResource: soundName, withExtension: fileExtension) {
			do {
				let audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
				audioPlayer.delegate = self
				audioPlayer.numberOfLoops = -1 // Loop sound after finished playing
				audioPlayers.append(audioPlayer)
				audioPlayer.prepareToPlay()
				audioPlayer.play()
				
				return audioPlayer
			} catch {
				print("Audio player failed to load")
				
				return nil
			}
		} else {
			print("Sound file not found")
			
			return nil
		}
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		if let index = audioPlayers.firstIndex(of: player) {
			audioPlayers.remove(at: index)
		}
	}
}
