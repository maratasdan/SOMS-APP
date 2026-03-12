//
//  DryerData.swift
//  SOMS
//
//  Created by Dan on 2/22/26.
//

import Foundation
import SwiftData

@Model
final class DryerData: Identifiable {
    
    var id: String
    var dmid: String
    var dhid: String
    var noh: String
    var date: String
    var time: String
    var upper: String
    var lower: String
    var boiler: String
    var mc: String
    var remarks: String
    var status: String
    var sl: String
    var startstrtime: String
    
    init(id: String = UUID().uuidString, dmid: String, dhid: String, noh: String, date: String, time: String, upper: String, lower: String, boiler: String, mc: String, remarks: String, status: String, sl: String, startstrtime: String) {
        
        self.id = id
        self.dmid = dmid
        self.dhid = dhid
        self.noh = noh
        self.date = date
        self.time = time
        self.upper = upper
        self.lower = lower
        self.boiler = boiler
        self.mc = mc
        self.remarks = remarks
        self.status = status
        self.sl = sl
        self.startstrtime = startstrtime
        
    }
    
}

