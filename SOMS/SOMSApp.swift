//
//  SOMSApp.swift
//  SOMS
//
//  Created by Dan XD on 2/19/26.
//

import SwiftUI
import SwiftData

@main
struct SOMSApp: App {

    
    let notificationDelegate = NotificationDelegate()
        
    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            Choose()
        }
        .modelContainer(for: [DryerHeader.self, DryerData.self, AppUser.self])
    }
}
