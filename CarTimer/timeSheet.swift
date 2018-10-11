//
//  timeSheet.swift
//  CarTimer
//
//  Created by Miguel Almeida on 09.10.18.
//  Copyright © 2018 Miguel Almeida. All rights reserved.
//

import Foundation

struct SpeedStep {
    
    var sSpeed = Double()
    var eSpeed = Double()
    var dTime = Double()
    
}

class TimeSheet {
    
    var speedSteps: [SpeedStep] = []
    
    init(){
        
        for i in stride(from: 0.0, to: 240.0, by: 10.0){
            
            var myStep = SpeedStep(sSpeed: i, eSpeed: i+10.0, dTime: 999)
            speedSteps.append(myStep)            
            
        }
    }
}
