//
//  SLHome.swift
//  SOMS
//
//  Created by Dan on 3/16/26.
//

import SwiftUI
import SwiftData

struct SLHome: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("loggedUsername") private var loggedUsername: String = ""

    @Query private var users: [AppUser]
    
    var body: some View {
        
        NavigationStack{
            slheader
            bodycontent
            
            
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
    private var slheader: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)

                Text(loggedUsername)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .font(.headline)

                Spacer()

                Button("Logout") {
                    loggedUsername = ""
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    private var bodycontent: some View {
        
        List{
            Section("Receiving"){
                NavigationLink(destination: SLMonitoring()){
                    Label("Monitoring Form", systemImage: "list.bullet")
                }
                NavigationLink(destination: ContentView()){
                    Label("Dryer", systemImage: "square.and.arrow.down")
                }
            }
        }
        
    }
}



#Preview {
    SLHome()
}
