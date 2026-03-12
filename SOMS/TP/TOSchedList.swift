//
//  TOSchedList.swift
//  SOMS
//
//  Created by Dan XD on 3/2/26.
//

import SwiftUI

struct TPSchedList: Identifiable, Codable {
    let id = UUID()
    var tplid: String
    var refno: String
    var hybrid_code: String
    var bpi_lot_no: String
    var location: String
    var com500_batch: String
    var quantity: String
    var com700_po: String?
    var com700_batch: String
    var expected_output: String
    var untreated_sample: String
    var status: String?
    var remarks: String?
    var created_at: String
    
    enum CodingKeys: String, CodingKey {
        case tplid, refno, hybrid_code, bpi_lot_no, location, com500_batch, quantity, com700_po, com700_batch, expected_output, untreated_sample, status, remarks, created_at
    }
}

struct TOSchedList: View {
    
    let refno: String
    
    @State var onlineTPList: [TPSchedList] = []
    
    var body: some View {
        NavigationStack {
            HStack{
                NavigationLink(destination: TPSchedules()){
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 30, height: 30)
                        
                }
                Spacer()
              
                
               
                
            }
            .padding(20)
            .padding(.bottom, 20)
            
            VStack{
                List(onlineTPList){ oltplist in
                    
                    if oltplist.status ?? "" == "2" {
                        NavigationLink(destination: ForceLandscapeView {
                            ViewList(tplid: oltplist.tplid)
                        }) {
                            VStack(alignment: .leading){
                                Text("\(oltplist.hybrid_code) | C500: \(oltplist.com500_batch) | C700: \(oltplist.com700_batch)")
                                    .font(.title2)
                                    .padding(.bottom, 10)
                                    .foregroundStyle(Color.blue)
                                VStack(alignment: .leading){
                                    HStack{
    //                                    Label("\(oltplist.tplid)", systemImage: "")
    //                                        .bold()
                                        Text("\(oltplist.tplid)")
                                            .bold()
                                        Spacer()
                                        Text("\(oltplist.location)")
                                            .bold()
                                        Spacer()
                                        Text("\(oltplist.quantity)")
                                            .bold()
                                    }
                                    
                                }
                            }
                            .padding()
                            .listRowBackground(Color.white)
                        }
                        .scrollContentBackground(.hidden)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }else{
                        NavigationLink(destination: ForceLandscapeView {
                            ViewList(tplid: oltplist.tplid)
                        }) {
                            VStack(alignment: .leading){
                                Text("\(oltplist.hybrid_code) | C500: \(oltplist.com500_batch) | C700: \(oltplist.com700_batch)")
                                    .font(.title2)
                                    .padding(.bottom, 10)
                                    .foregroundStyle(Color.blue)
                                VStack(alignment: .leading){
                                    HStack{
    //                                    Label("\(oltplist.tplid)", systemImage: "")
    //                                        .bold()
                                        Text("\(oltplist.tplid)")
                                            .bold()
                                        Spacer()
                                        Text("\(oltplist.location)")
                                            .bold()
                                        Spacer()
                                        Text("\(oltplist.quantity)")
                                            .bold()
                                    }
                                    
                                }
                            }
                            .padding()
                            .listRowBackground(Color.white)
                        }
                        .scrollContentBackground(.hidden)
                        .cornerRadius(10)
                    }
                    
                    
                }
            }
            .onAppear{
                fetchTPDataList()
            }
        }
        .navigationTitle("List")
        .navigationBarBackButtonHidden(true)
    }
    
    func fetchTPDataList() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/getTPSchedList.php?refno=\(refno)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([TPSchedList].self, from: data)
                    DispatchQueue.main.async {
                        self.onlineTPList = decoded
                    }
                } catch {
                    print("Error decoding:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
}

#Preview {
    TOSchedList(refno: "83-678-63")
}
