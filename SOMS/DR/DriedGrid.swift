//
//  DriedGrid.swift
//  SOMS
//
//  Created by Dan on 3/18/26.
//

import SwiftUI
import SwiftData

struct DriedGrid: View {
    
    @Query private var dyerheaderlist: [DryerHeader]
    
    var body: some View {
        
        NavigationStack {
            List(dyerheaderlist) { drh in
                
                if drh.status == "4.1" {
                    VStack {
                        HStack {
                            Text("\(drh.dhid)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(drh.binid)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(drh.rhid)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(drh.skind)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(drh.status)")
                                .font(.headline)
                        }
                    }
                }
                
            }
        }
        .navigationTitle("Dried Grids")
        
        
    }
}

#Preview {
    DriedGrid()
}
