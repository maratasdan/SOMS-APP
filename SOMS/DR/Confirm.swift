import SwiftUI
import SwiftData

struct ConfirmDRHeader: Codable, Identifiable {
    let id = UUID()
    var dhid: String
    var rhid: String
    var binid: String
    var lot_no: String
    var status: String
    var initial_mc: String
    var start: String
    var end: String
    var reversal: String
}

struct Confirm: View {
    
    @Environment(\.modelContext) private var context
    
    @State private var onlinedrh: [ConfirmDRHeader] = []
    @State private var selectedItem: ConfirmDRHeader?
    
    @State private var isSheetMigrateOpen = false
    @State private var goToAdopt = false
    @State private var isDataLoading = false
    @State private var progress: Double = 0.0
    @State private var alertError = false
    
    @State private var srhid: String = ""
    @State private var sdhid: String = ""
    
    @Environment(\.modelContext) private var modelContext
    @Query private var dryerData: [DryerData]
    
    var isoString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Mas reliable for fixed format
        formatter.timeZone = TimeZone.current                  // Gamiton ang local time
        return formatter.string(from: Date())
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        
        
        NavigationStack {
            
            List(onlinedrh) { confdh in
                
                VStack(alignment: .leading) {
                    
                    Label(confdh.binid, systemImage: "flame")
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack {
                        Label(confdh.rhid, systemImage: "widget.small")
                            .font(.caption2)
                        
                        Spacer()
                        
                        Text(confdh.lot_no)
                            .font(.caption2)
                        
                    }
                }
                .swipeActions {
                    Button("Migrate") {
                        selectedItem = confdh
                        isSheetMigrateOpen = true
                    }
                    .tint(.blue)
                }
            }
            .navigationTitle("Confirmation List")
            .onAppear {
                fetchDRData()
            }
            .navigationDestination(isPresented: $goToAdopt){
//                Adopt(srhid: srhid, sdhid: sdhid)
                Grid()
            }
            .alert("Error", isPresented: $alertError){
                Text("Error")
            }
            
        }
        
        // ✅ Confirmation Sheet
        .sheet(isPresented: $isSheetMigrateOpen) {
            VStack(spacing: 20) {
                
                Text("Are you sure?")
                    .font(.title2)
                
                Image(systemName: "square.and.arrow.down.on.square")
                    .font(.system(size: 60))
                
                Button("Confirm") {
                    if let item = selectedItem {
                        isSheetMigrateOpen = false
                        isDataLoading = true
                        
                        addItem(
                            dhid: item.dhid,
                            rhid: item.rhid,
                            binid: item.binid,
                            lot_no: item.lot_no,
                            status: item.status,
                            initial_mc: item.initial_mc,
                            start: item.start,
                            end: item.end,
                            reversal: item.reversal
                        )
                        
                        addDataDryerHeader(dhid: item.dhid, initial_mc: item.initial_mc)
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Cancel") {
                    isSheetMigrateOpen = false
                }
                .foregroundColor(.blue)
            }
            .padding()
            .presentationDetents([.fraction(0.4)])
            
            
        }
        
        // ✅ Loading Sheet
        .sheet(isPresented: $isDataLoading) {
            VStack(spacing: 10) {
                ProgressView("Migrating...", value: min(max(progress, 0), 1))
//              
            }
            .padding()
            .presentationDetents([.fraction(0.2)])
            .interactiveDismissDisabled(true)
        }
    }
    
    
    // MARK: - Local Database Save
    
    func addDataDryerHeader(dhid: String, initial_mc: String){
        
        let newData = DryerData(dmid: UUID().uuidString, dhid: dhid, noh: "00:00:00", date: isoString, time: currentTime, upper: "0", lower: "0", boiler: "0", mc: initial_mc, remarks: "NA", status: "1", sl: "0", startstrtime: "0")
        
        modelContext.insert(newData)
        print("First Dryer Data Saved")
    }
    
    func addItem( dhid: String, rhid: String, binid: String, lot_no: String, status: String, initial_mc: String, start: String, end: String, reversal: String) {
        
        let item = DryerHeader(
            dhid: dhid,
            rhid: rhid,
            binid: binid,
            lot_no: lot_no,
            status: status,
            initial_mc: initial_mc,
            start: start,
            end: end,
            reversal: reversal
        )
        
        context.insert(item)
        
        simulateProgress(rhid: rhid, dhid: dhid)
        
    }
    
    
    // MARK: - Progress Animation
    
    func simulateProgress(rhid: String, dhid: String) {
        
        progress = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { timer in
            
            if progress < 1.0 {
                progress += 0.1
            } else {
                timer.invalidate()
                
                isDataLoading = false
                progress = 0
                
                // remove migrated item from list
                if let selected = selectedItem {
                    onlinedrh.removeAll { $0.id == selected.id }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    
                    updateDataMigrate(rhidx: rhid, dhidx: dhid)
                    
                }
                
            }
        }
    }
    
    
    // MARK: - Online Fetch
    
    func updateDataMigrate(rhidx: String, dhidx: String){
        
//        print(dhidx)
       
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/updateConfirmMigrate.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "dhid=\(dhidx)x&rhid=\(rhidx)x"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "Done" {
                    goToAdopt = true
                    srhid = rhidx
                    sdhid = dhidx
                    
                }else if result == "Error"{
                    alertError = true
                }
            }
        }.resume()
        
    }
    
    func fetchDRData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/getToDry.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([ConfirmDRHeader].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.onlinedrh = decoded
                    }
                    
                } catch {
                    print("Error decoding:", error)
                }
            }
            
        }.resume()
    }
}

#Preview {
    Confirm()
}
