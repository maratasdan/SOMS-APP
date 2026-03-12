//
//  DRHome.swift
//  SOMS
//
//  Created by Dan on 3/18/26.
//

import SwiftUI

struct DRHome: View {
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("loggedUsername") private var loggedUsername: String = ""
    
    var body: some View {
        VStack{
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading){
                    Label("", systemImage: "person.circle")
                }
            }
            
            List {
                NavigationLink(destination: Grid()){
                    Label("Drying Grids", systemImage: "flame.circle")
                }
                NavigationLink(destination: Grid()){
                    Label("Migrate Grids", systemImage: "arrow.down.circle")
                }
            }
            
        }
    }
}

#Preview {
    DRHome()
}
