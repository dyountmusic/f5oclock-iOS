//
//  RealTimeRefreshHandler.swift
//  F5OClock
//
//  Created by Daniel Yount on 10/14/17.
//  Copyright © 2017 Daniel Yount. All rights reserved.
//

import Foundation

class RealTimeRefreshHandler {
    
    var isRealTime = false
    
    weak var timer: Timer?
    var timerDispatchSourceTimer : DispatchSourceTimer?
    
    func startTimer(viewController: TopStoryViewController) {
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                // do something here
                print("Timer has fired!")
                viewController.updateUI()
                
            }
            
        } else {
            // Fallback on earlier versions
            timerDispatchSourceTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            timerDispatchSourceTimer?.scheduleRepeating(deadline: .now(), interval: .seconds(60))
            timerDispatchSourceTimer?.setEventHandler{
                // do something here
                print("Timer has fired!")
                viewController.updateUI()
            }
            timerDispatchSourceTimer?.resume()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        //timerDispatchSourceTimer?.suspend() // if I want to suspend timer
        timerDispatchSourceTimer?.cancel()
    }
    
    
    
}
