//
//  DRGrid.swift
//  SOMS
//
//  Created by Dan on 3/18/26.
//

import SwiftUI
import SwiftData

struct DRGrid: View {
    
    @Environment(\.modelContext) private var context
    @Query private var dyerheaderlist: [DryerHeader]
    
    @StateObject var timer = CountdownTimer()
    @State private var startDate = ""

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {

        ZStack {
            ScrollView {
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(1...9, id: \.self) { _ in }
                }
                .padding()
                .padding(.vertical, 20)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(dyerheaderlist) { list in
                        if list.status == "4" {
                            NavigationLink {
                                Panel(
                                    dhid: list.dhid,
                                    startDate: list.start,
                                    rhid: list.rhid,
                                    binid: list.binid,
                                    lotno: list.lot_no
                                )
                            } label: {
                                DryerHeaderCard(list: list)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .padding()
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

// 🔥 FIXED CARD
private struct DryerHeaderCard: View {
    let list: DryerHeader

    @Query private var data: [DryerData]

    init(list: DryerHeader) {
        self.list = list
        
        let dhidValue = list.dhid // ✅ FIX
        
        _data = Query(
            filter: #Predicate<DryerData> { $0.dhid == dhidValue },
            sort: \DryerData.startstrtime,
            order: .reverse
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("\(list.binid)")
                    .font(.title)
                    .foregroundStyle(Color.blue)
                    .bold()

                Spacer()

                Image(systemName: "chevron.right")
            }

            Spacer()

            HStack {
                HStack {
                    Image("seeding")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text(list.skind == "0" ? "Rice" : "Corn")
                        .foregroundStyle(Color.blue)
                        .bold()
                }

                Spacer()

                HStack {
                    Image("swap")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    if list.start_half.isEmpty {
                        Text("")
                            .foregroundStyle(Color.blue)
                            .bold()
                    }else{
                        Text(list.start_half.replacingOccurrences(of: ".000000", with: ""))
                            .foregroundStyle(Color.blue)
                            .bold()
                    }
                    
//
                }
            }

            HStack {
                HStack {
                    Image("water-stream")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("\(list.initial_mc)")
                        .foregroundStyle(Color.blue)
                        .bold()
                }

                Spacer()

                HStack {
                    Image("thermometer")
                        .resizable()
                        .frame(width: 20, height: 20)

                    // 🔥 LATEST DATA
                    if let latest = data.last {
                        HStack {
                            Label("\(latest.upper)", systemImage: "arrow.up")
                                .foregroundStyle(Color.blue)
                                .bold()
                            
                            Label("\(latest.lower)", systemImage: "arrow.down")
                                .foregroundStyle(Color.blue)
                                .bold()
                        }
                    } else {
                        Text("No Data")
                            .foregroundStyle(Color.gray)
                    }
                }
            }

            HStack {
                HStack {
                    Image("flax-seed")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    Text("\(list.hybrid_code ?? "")")
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

#Preview {
    DRGrid()
}
