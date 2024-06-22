//
//  SFXManager.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 21/06/24.
//

import Foundation
import AVFoundation

class SFXManager: NSObject, AVAudioPlayerDelegate {
    static let shared = SFXManager()
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    private override init() {
        
    }
    
    func playSFX(name: String, type: String, completion: (() -> Void)? = nil){
        if let path = Bundle.main.path(forResource: name, ofType: type){
            let url = URL(filePath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                self.completionHandler = completion
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error.localizedDescription)")
            }
        }
    }
    
    func stopSFX(){
        audioPlayer?.stop()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        completionHandler?()
        completionHandler = nil
    }
}
