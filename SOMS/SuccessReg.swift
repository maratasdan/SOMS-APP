//
//  SuccessReg.swift
//  SOMS
//
//  Created by Dan on 3/13/26.
//

import SwiftUI
import SwiftData

struct SuccessReg: View {
    @Query private var users: [AppUser]
    
    @State private var goToLogin: Bool = false

    var body: some View {
        
        NavigationStack {
            Image(systemName: "check.circle")
            
            Text("Successfuly Registered!")
                .font(.title)
                .padding(.bottom, 20)
            
            Button(action: {
                goToLogin = true
            }) {
                
                Text("Go to Login")
            }
            .navigationDestination(isPresented: $goToLogin) {
                Login()
            }
        }
        
        
        
        
//        List(users) { user in
//            VStack(alignment: .leading, spacing: 4) {
//                Text("\(user.first_name) \(user.last_name)")
//                    .font(.headline)
//                Text("Username: \(user.username)")
//                Text("Password: \(user.password)")
//                Text("User ID: \(user.userid)")
//                Text("Level: \(user.user_level_id) • Status: \(user.status)")
//                if let gender = user.gender {
//                    Text("Gender: \(gender)")
//                }
//                if let position = user.position {
//                    Text("Position: \(position)")
//                }
//            }
//        }
//        .navigationTitle("All Users")
    }
}

#Preview {
    SuccessReg()
}
