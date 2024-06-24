//
//  CountdownTimer.swift
//  ForStayingAlive
//
//  Created by Rangga Saputra on 19/06/24.
//

import Foundation

class CountdownTimer {
    var totalTime: TimeInterval
    var remainingTime: TimeInterval
    
    init(totalTime: TimeInterval) {
        self.totalTime = totalTime
        self.remainingTime = totalTime
    }
    
    func updateTime(by timeInterval: TimeInterval) {
        remainingTime -= timeInterval
        if remainingTime < 0 {
            remainingTime = 0
        }
    }
}
