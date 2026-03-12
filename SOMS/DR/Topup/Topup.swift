//
//  Topup.swift
//  SOMS
//
//  Created by Dan XD on 2/26/26.
//

import SwiftUI
import SwiftData

struct TopupHeader: Identifiable, Codable {
    let id = UUID()
    var dhid: String
    var rhid: String
    var start: String
    var binid: String
    var lot_no: String
    var nwmcstat: String

    enum CodingKeys: String, CodingKey {
        case dhid
        case start
        case rhid
        case binid
        case lot_no
        case nwmcstat
    }
}

struct TopupDetail: Identifiable, Codable {
    
    let id = UUID()
    var dhid: String
    var noh: String
    var date: String
    var time: String
    var upper: String
    var lower: String
    var boiler: String
    var mc: String
    var remarks: String
    var status: String
    
}

struct Topup: View {
    
    @State private var isDataLoading: Bool = false
    @State private var goToPanel: Bool = false
    
    @State private var topupHeaders: [TopupHeader] = []
    @State private var topupDetails: [TopupDetail] = []
    
    @State private var progress: Double = 0.0
    
    @State private var dhid: String = ""
    @State private var rhid: String = ""
    @State private var start: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @Query private var dryerData: [DryerData]
    
    
    var elapsedSinceStart: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let parsedDate = inputFormatter.date(from: start) else {
            return ""
        }
        
        let interval = Date().timeIntervalSince(parsedDate)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: interval) ?? "00:00:00"
    }
    
    var currentDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                
                List(topupHeaders) { tp in
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Image(systemName: "flame")
                            Text(tp.binid)
                        }
                        .font(.headline)
                        
                        Spacer()
                        
                        HStack {
                            Label(tp.dhid, systemImage: "widget.small")
                                .font(.caption2)
                            
                            Spacer()
                            
                            Text(tp.lot_no)
                                .font(.caption2)
                        }
                    }
                    .swipeActions(edge: .trailing){
                        Button(action: {
                            isDataLoading = true
                            simulateProgress(dhid: tp.dhid, start: tp.start, rhid: tp.rhid)
                        }){
                            Label("Topup", systemImage: "")
                                .tint(Color.blue)
                        }
                    }
                }
                .onAppear{
                    fetchTPdata()
                }
                
            }
            .sheet(isPresented: $isDataLoading) {
                VStack(spacing: 10) {
                    ProgressView("Calculating...", value: min(max(progress, 0), 1))
                }
                .padding()
                .presentationDetents([.fraction(0.2)])
                .interactiveDismissDisabled(true)
            }
            
//            NavigationLink(
//                destination: Panel(dhid: dhid, startDate: start, rhid: rhid),
//                isActive: $goToPanel
//            ) {
//                
//            }
            
        }
        .navigationTitle("Topup")
    }
    
    func simulateProgress(dhid: String, start: String, rhid: String) {
        
        progress = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            
            if progress < 1.0 {
                progress += 0.1
            } else {
                timer.invalidate()
                
                isDataLoading = false
                progress = 0
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
//                    updateDataMigrate(rhidx: rhid, dhidx: dhid)
                    
                    
                    getTopUpData()
                    
                    self.dhid = dhid
                    self.rhid = rhid
                    self.start = start
                    
                    print(start)
                    print(elapsedSinceStart)
                    
                }
                
            }
        }
    }
    
    func addDataDryerHeader(noh: String, date: String, time: String, upper: String, lower: String, mc: String, remarks: String, sl: String){
        
        
        let newData = DryerData(dmid: UUID().uuidString, dhid: dhid, noh: noh, date: date, time: time, upper: upper, lower: lower, boiler: "", mc: mc, remarks: remarks, status: "1", sl: sl, startstrtime: "")
        
        modelContext.insert(newData)
        
        print("Na add na ang topup")
      
    }
    
    private func sendDataTopUp(){
        
        guard let latest = topupDetails.first else {
            print("No topup details available")
            return
        }
        
        if latest.dhid == dhid {
            print("Hello itsme: \(latest.noh)")
            print("Hello itsmex: \(elapsedSinceStart)")
        }
        
        
    }
    
    private func getTopUpData(){
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/topUp.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "rhid=\(rhid)&tptimer=\(elapsedSinceStart)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
              
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let decoded = try decoder.decode([TopupDetail].self, from: data)
                    DispatchQueue.main.async {
                        topupDetails = decoded
                        sendDataTopUp()
                    }
                } catch {
                    print("Error decoding:", error)
                }
                
            }
            
        }.resume()
    }
    
    
//    private func sendDataForTopUp(){
//        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/topUp.php") else { return }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .useDefaultKeys
//                    let decoded = try decoder.decode([TopupDetail].self, from: data)
//                    DispatchQueue.main.async {
//                        topupDetails = decoded
//                        sendDataTopUp()
//                    }
//                } catch {
//                    print("Error decoding:", error)
//                }
//            }
//        }.resume()
//    }
    
    private func fetchTPdata() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/getTopUp.php") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    let decoded = try decoder.decode([TopupHeader].self, from: data)
                    DispatchQueue.main.async {
                        topupHeaders = decoded
                    }
                } catch {
                    print("Error decoding:", error)
                }
            }
        }.resume()
    }
}

#Preview {
    Topup()
}

