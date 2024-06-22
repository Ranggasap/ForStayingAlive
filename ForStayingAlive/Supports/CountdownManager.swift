//
//  CountdownManager.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 19/06/24.
//

import Foundation
import Combine

class CountdownManager: ObservableObject {
    @Published var displayTime: String = "--:--"
    private var timer: CountdownTimer
    private var cancellable: AnyCancellable?
    
    init(totalTime: CGFloat){
        self.timer = CountdownTimer(totalTime: totalTime)
    }
    
    func updateTimer(dt: TimeInterval){
        timer.updateTime(by: dt)
        let minutes = Int(timer.remainingTime) / 60
        let seconds = Int(timer.remainingTime) % 60
        displayTime = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getTimer() -> CountdownTimer{
        return timer
    }
}
