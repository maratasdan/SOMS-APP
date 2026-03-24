//
//  AppUser.swift
//  SOMS
//
//  Created by Dan on 3/13/26.
//

import Foundation
import SwiftData

@Model
final class AppUser: Identifiable {
    
    var id: String
    var userid: String
    var username: String
    var password: String
    var user_level_id: String
    var status: String
    var first_name: String
    var last_name: String
    var gender: String?
    var position: String?
    
    init(id: String = UUID().uuidString, userid: String, username: String, password: String, user_level_id: String, status: String, first_name: String, last_name: String, gender: String? = nil, position: String? = nil) {
        
        self.id = id
        self.userid = userid
        self.username = username
        self.password = password
        self.user_level_id = user_level_id
        self.status = status
        self.first_name = first_name
        self.last_name = last_name
        self.gender = gender
        self.position = position
        
    }
    
}
