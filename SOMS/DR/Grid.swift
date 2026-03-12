//
//  Grid.swift
//  SOMS
//
//  Created by Dan XD on 2/19/26.
//

import SwiftUI
import SwiftData

struct Grid: View {
    
    @Environment(\.modelContext) private var context
    @Query private var dyerheaderlist: [DryerHeader]
    
    @StateObject var timer = CountdownTimer()
    
    @State private var startDate = ""

    var body: some View {
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        let columnsx = [
                GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        NavigationStack {
            ZStack {
                
                Image("trbg3")
                        .resizable()
                        .ignoresSafeArea()
                
                ScrollView {
                    
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                                
                            ForEach(1...9, id: \.self) { item in
                                
                                
                            }
                            
                        }
                        .padding()
                        .padding(.vertical, 20)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        ForEach(dyerheaderlist) { list in
                            
                            VStack(alignment: .leading) {
                                
                                HStack{
//                                        Label("44", systemImage: "flame.circle")
//                                            .font(.title2)
//                                            .tint(.red)
                                    Text("\(list.binid)")
                                        .font(.title)
                                        .foregroundStyle(Color.blue)
                                        .bold()
                                    
                                    Spacer()
                                    
                                        NavigationLink(destination: Panel(dhid: list.dhid, startDate: list.start, rhid: list.rhid)) {
                                            Image(systemName: "chevron.right")
                                        }
                                }
                                
                                Spacer()
                                
                                HStack{
                                    HStack{
                                        Image("seeding")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Corn")
                                            .foregroundStyle(Color.blue)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    HStack{
                                        Image("swap")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Mar 13, Fri 07:40:09 AM")
                                            .foregroundStyle(Color.blue)
                                            .bold()
                                    }
                                    
                                }
                                
                                HStack{
                                    HStack{
                                        Image("water-stream")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("\(list.initial_mc)")
                                            .foregroundStyle(Color.blue)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    HStack{
                                        Image("thermometer")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("↑35.3 - ↓38.5")
                                            .foregroundStyle(Color.blue)
                                            .bold()
                                    }
                                    
                                }
                                HStack{
                                    HStack{
                                        Image("flax-seed")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("Cell")
                                            .foregroundStyle(Color.blue)
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    
                                    
                                    
                                }
                                
                            }
                            .padding(30)
                            .background(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.blue, lineWidth: 3)
                                    
                            )
                            .frame(height: 230)
                            
                        }
                    }
                    .padding()
                }
                .padding()
            }
            }
            .navigationTitle("Drying List")
            .onAppear {
                print("Fetched count:", dyerheaderlist.count)
            }
        
    }

    func deleteAll() {
        
        for item in dyerheaderlist {
            context.delete(item)
        }
        do {
            try context.save()
            print("Deleted all DryerHeader")
        } catch {
            print("Delete error:", error)
        }
        
    }
}


#Preview {
    Grid()
}
