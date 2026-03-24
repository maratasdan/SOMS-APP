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
        NavigationStack {
            VStack{
                
                VStack(alignment: .leading) {
                    HStack{
                        Label("\(loggedUsername)", systemImage: "person.circle")
                            .font(Font.system(size: 20))
                        Spacer()
                        Button(){
                            dismiss()
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                                .foregroundStyle(Color.red)
                        }
                    }
                    .padding(10)
                    .padding(.leading, 29)
                    .padding(.trailing, 29)
                }
                
                List {
                    NavigationLink(destination: DRGrid()){
                        Label("Drying Grids", systemImage: "flame.circle")
                    }
                    NavigationLink(destination: Confirm()){
                        Label("Migrate Grids", systemImage: "arrow.down.circle")
                    }
                    NavigationLink(destination: DriedGrid()){
                        Label("Dried Grids", systemImage: "arrow.down.circle")
                    }
                }
                
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DRHome()
}
