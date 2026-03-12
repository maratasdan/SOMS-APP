//
//  CountdownTimer.swift
//  SOMS
//
//  Created by Dan on 2/22/26.
//

import Foundation
import Combine

class CountdownTimer: ObservableObject {
    
    @Published var remainingTime: Int = 0   // seconds
    
    private var timer: Timer?
    
    // Call this to start countdown
    func start(hours: Int) {
        remainingTime = hours * 3600
        
        timer?.invalidate()  // stop previous timer if any
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                print("Countdown finished!")
            }
        }
    }
    
    // Optional: Stop timer anytime
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    // Format seconds -> hh:mm:ss
    func timeString() -> String {
        let h = remainingTime / 3600
        let m = (remainingTime % 3600) / 60
        let s = (remainingTime % 3600) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

