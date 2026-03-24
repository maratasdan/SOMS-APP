//
//  TPSchedules.swift
//  SOMS
//
//  Created by Dan XD on 3/2/26.
//

import SwiftUI

struct TPSchedulesHead: Identifiable, Codable {
    let id = UUID()
    var tpid: String
    var refno: String
    var name: String
    var tpoperator: String?
    var tppreparedby: String?
    var tpvalidated: String?
    var date_created: String
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        case tpid, refno, name, tpoperator, tppreparedby, tpvalidated, date_created, status
    }
}

struct TPSchedules: View {
    
    @State private var onlineTPhead: [TPSchedulesHead] = []
    
    var body: some View {
        NavigationStack {
            HStack{
//                NavigationLink(destination: ContentView()){
//                    Image(systemName: "arrow.left")
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        
//                }
//                Spacer()
              
                
               
                
            }
            .padding(20)
            .padding(.bottom, 20)
            VStack{
                List(onlineTPhead){ otph in
                    VStack{
                        NavigationLink(destination: TOSchedList(refno: otph.refno)){
                            VStack(alignment: .leading){
                                Text(otph.name)
//                                Label("\(otph.name)", systemImage: "arrow.2.circlepath.circle")
                                Spacer()
                                Text(otph.date_created)
                                    .font(.footnote)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Schedules")
        .onAppear{
            fetchTPData()
        }
    }
    
    func fetchTPData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/getTPSched.php") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([TPSchedulesHead].self, from: data)
                    DispatchQueue.main.async {
                        self.onlineTPhead = decoded
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
    TPSchedules()
}
