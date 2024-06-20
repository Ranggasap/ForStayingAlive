//
//  CountdownTimerViewModel.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 19/06/24.
//

import Foundation
import Combine

class CountdownTimerViewModel: ObservableObject {
    @Published var displayTime: String = "--:--"
    private var timer: CountdownTimer
    private var cancellable: AnyCancellable?
    
    init(){
        self.timer = CountdownTimer(totalTime: 300)
    }
    
    func startTimer(){
        cancellable = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink{ [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer(){
        timer.updateTime(by: 1)
        let minutes = Int(timer.remainingTime) / 60
        let seconds = Int(timer.remainingTime) % 60
        displayTime = String(format: "%02d:%02d", minutes, seconds)
    }
}
