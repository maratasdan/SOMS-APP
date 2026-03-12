//
//  RefreshPage.swift
//  SOMS
//
//  Created by Dan XD on 3/3/26.
//

import SwiftUI

struct RefreshPage: View {
    
    @State private var goToRefreshPage = false
    
    let tplid: String
    
    var body: some View {
        NavigationStack {
            NavigationLink("", destination: ViewList(tplid: tplid), isActive: $goToRefreshPage)
                .hidden()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                goToRefreshPage.toggle()
            }
        }
    }
}

#Preview {
    RefreshPage(tplid: "97")
}
