//
//  ApproveBinsConfirm.swift
//  SOMS
//
//  Created by Dan on 3/24/26.
//

import SwiftUI

struct BinOverview: Identifiable, Codable {
    let id = UUID()
    var binid: String
    var hybrid_code: String
    var field_quality: String
}

struct ApproveBinsConfirm: View {
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("loggedUsername") private var loggedUsername: String = ""
    
    let rhid: String
    
    @State var binOverview: [BinOverview] = []
    
    @State var goBackToAB: Bool = false
    
    var body: some View {
        NavigationStack{
            List {
                Section("Overview"){
                    Label("Syngenta", systemImage: "person.2")
                    Label("\(binOverview.first?.binid ?? "")", systemImage: "arrow.up.bin")
                    Label("\(binOverview.first?.hybrid_code ?? "")", systemImage: "poweroff")
                    Label("\(binOverview.first?.field_quality ?? "")", systemImage: "homepod.badge.checkmark.fill")
                }
                
                HStack{
                    Button(action: {
                        approveBin(rhid: rhid, status: "0.5", type: "1", userid: loggedUsername)
                    }){
                        Text("Approve")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                    }
                    .buttonStyle(.glassProminent)
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        approveBin(rhid: rhid, status: "1_1", type: "2", userid: loggedUsername)
                    }){
                        Text("Decline")
                            .frame(maxWidth: .infinity)
                            .font(.title2)
                            
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundStyle(Color.white)
                    .cornerRadius(20)
                    
                }
              
            }
            .navigationDestination(isPresented: $goBackToAB) {
                ApproveBins()
            }
        }
        .onAppear(){
            fetchDRData()
        }
    }
    
    func approveBin(rhid: String, status: String, type: String, userid: String){
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/SL/btnApproveBin.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "rhid=\(rhid)&status=\(status)&userid=\(userid)&type=\(type)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "1" {
                    goBackToAB = true
                }else if result == "2" {
                    goBackToAB = true
                }
                
            }
            
        }.resume()
        
    }
    
    func fetchDRData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/SL/binOverview.php?rhid=\(rhid)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([BinOverview].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.binOverview = decoded
                    }
                    
                } catch {
                    print("Error decoding:", error)
                }
            }
            
        }.resume()
    }
    
}

#Preview {
    ApproveBinsConfirm(rhid: "RH02205")
}
