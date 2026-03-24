//
//  DryerHeader.swift
//  SOMS
//
//  Created by Dan XD on 2/19/26.
//

import Foundation
import SwiftData

@Model
final class DryerHeader: Identifiable {
    
    var id: String
    var dhid: String
    var rhid: String
    var binid: String
    var lot_no: String
    var status: String
    var initial_mc: String
    var start: String
    var start_half: String
    var end: String
    var reversal: String
    var skind: String
    var hybrid_code: String

    init(id: String = UUID().uuidString, dhid: String, rhid: String, binid: String, lot_no: String, status: String, initial_mc: String, start: String, start_half: String, end: String, reversal: String, skind: String, hybrid_code: String) {
    
        self.id = id
        self.dhid = dhid
        self.rhid = rhid
        self.binid = binid
        self.lot_no = lot_no
        self.status = status
        self.initial_mc = initial_mc
        self.start = start
        self.start_half = start_half
        self.end = end
        self.reversal = reversal
        self.skind = skind
        self.hybrid_code = hybrid_code
        
    }
}
