//
//  ApproveBins.swift
//  SOMS
//
//  Created by Dan on 3/24/26.
//

import SwiftUI

struct GetBinsOverview: Identifiable, Codable {
    let id = UUID()
    var rhid: String
    var date: String
    var binid: String
    var lot_no: String
}

struct ApproveBins: View {
    
   @State var getbinOverview: [GetBinsOverview] = []
    
    var body: some View {
        NavigationStack{
            
            List(getbinOverview) { bin in
                
                NavigationLink(destination: ApproveBinsConfirm(rhid: bin.rhid)){
                    VStack(alignment: .leading){
                        HStack{
                            Label("\(bin.binid)", systemImage: "flame.circle")
                            Spacer()
                            Text("\(bin.rhid)")
                            Spacer()
                            Text("\(bin.date)")
                        }
                    }
                }
                
            }
            
        }
        .onAppear(){
            fetchDRData()
        }
    }
    
    func fetchDRData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/SL/getBinsOverview.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([GetBinsOverview].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.getbinOverview = decoded
                    }
                    
                } catch {
                    print("Error decoding:", error)
                }
            }
            
        }.resume()
    }
    
}

#Preview {
    ApproveBins()
}
