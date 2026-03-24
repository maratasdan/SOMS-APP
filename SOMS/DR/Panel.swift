//
//  Panel.swift
//  SOMS
//
//  Created by Dan on 2/21/26.
//

import SwiftUI
import SwiftData
import UserNotifications
import Network

import CoreNFC
import Combine

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label // The button's label content
            .padding()
            .background(configuration.isPressed ? Color.blue.opacity(0.5) : Color.blue) // Change background on press
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // Add a press animation
    }
}

struct Panel: View {
    
//  NFC
    @StateObject private var nfcReader = NFCLoginReader()
    @State private var expectedToken = "NFC_LOGIN_TOKEN"
    
    @State private var goToNFC: Bool = false
    
//  Variables
    var dhid: String
    var startDate: String
    var rhid: String
    var binid: String
    var lotno: String
    
    @AppStorage("loggedUsername") private var loggedUsername: String = ""
    @AppStorage("loggedUserid") private var loggedUserid: String = ""
    
    @State private var latestDateSave = ""
    
//  Textfield
    @State private var upperTemp = ""
    @State private var lowerTemp = ""
    @State private var mcnt = ""
    @State private var comment = ""
    @State private var errorMessage = ""
    
//  DB related
    @Environment(\.modelContext) private var modelContext
    @Query private var dryerData: [DryerData]
    
    @Query(sort: \DryerData.date, order: .reverse)
    private var dryerDataSorted: [DryerData]
    
    @Query private var dryerHeaders: [DryerHeader]
    
    @Query private var users: [AppUser]
    
//  Sheet Related
    @State private var isOpenAddItem: Bool = false
    @State private var isConfirmAddItem: Bool = false
    @State private var isEditItem: Bool = false
    @State private var isReversal: Bool = false
    @State private var isConfirmUpdateReversal: Bool = false
    @State private var isUpdateReversalNoInternet: Bool = false
    @State private var isConfirmInternet: Bool = false
    @State private var isShutOff: Bool = false
    @State private var shutoffmc: String = ""
    @State private var backToGrid: Bool = false
    
    @State private var showAlertNoInternet: Bool = false
    @State private var showAlertHaveInternet: Bool = false
    @State private var checkIfInternet = ""
    
    @State private var listBackgroundColor = ""
    
//    var elapsedSinceStart: String {
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        guard let parsedDate = inputFormatter.date(from: start) else {
//            return ""
//        }
//        
//        let interval = Date().timeIntervalSince(parsedDate)
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.unitsStyle = .positional
//        formatter.zeroFormattingBehavior = [.pad]
//        return formatter.string(from: interval) ?? "00:00:00"
//    }
//    
//  Time Related
    var isoString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Mas reliable for fixed format
        formatter.timeZone = TimeZone.current                  // Gamiton ang local time
        return formatter.string(from: Date())
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
    
    var latestDateAdded: String {
        // Return the date of the most recent DryerData matching this dhid (array is already sorted by date desc)
        if let match = dryerDataSorted.first(where: { $0.dhid == dhid }) {
            return match.date
        }
        return ""
    }
    
    var elapsedSinceStart: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let parsedDate = inputFormatter.date(from: startDate) else {
            return ""
        }
        
        let interval = Date().timeIntervalSince(parsedDate)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: interval) ?? "00:00:00"
    }
    
    
    
    var body: some View {
        
        

        NavigationStack {
            VStack{
                VStack(alignment: .trailing) {
                    HStack{
                        
//                        Button(action: {
//                            
//                        }){
//                            Label("View Details", systemImage: "arrow.2.circlepath.circle")
//                        }
                        
                        Button(action: {
                            sendAllByDHID(dhidValue: dhid)
                        }){
                            Label("Update", systemImage: "arrow.2.circlepath.circle")
                        }
                        
                    }
//                    VStack{
//                        Text("\(loggedUsername) - \(loggedUserid)")
//                    }
                }
//              MARK: List
                List(dryerDataSorted) { dd in
                    if dd.dhid == dhid{
                        VStack(alignment: .leading){
//                            HStack{
//                                Text(formatToReadable(dd.date))
//                                    .bold()
//                            }
//                            HStack{
//                                Label("\(dd.noh)", systemImage: "clock")
//                                Spacer()
//                                Label("\(dd.time)", systemImage: "")
//                            }
//                            Spacer()
                            HStack{
                                Label("\(dd.upper)", systemImage: "arrow.up")
                                Spacer()
                                Label("\(dd.lower)", systemImage: "arrow.down")
                                Spacer()
                                Label("\(dd.mc)°", systemImage: "drop.degreesign")
                            }
                            Spacer()
                            Spacer()
                            VStack{
                                Text("Remarks: \(dd.remarks)")
                                    .font(.footnote)
                            }
                        }
                        .swipeActions(){
                            Button(action: {
                               
                            }){
                                Image(systemName: "square.and.pencil")
                                    .tint(.blue)
                            }
                        }
                        .padding()
                        .background(Color.white)   // white bg for cell
                        .cornerRadius(8)           // optional rounded corner
                        .listRowInsets(EdgeInsets()) // remove default padding
                        .listRowBackground(Color.clear)
                    }
                    
                }
                .listStyle(PlainListStyle())
                .onAppear{
                    sendAllByDHID(dhidValue: dhid)
                }
                
            }
            .onAppear{
                sendAllByDHID(dhidValue: dhid)
            }
            .onAppear {
                UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound]) { success, error in
                        if success {
                            print("Allowed")
                        }
                    }
            }
            .sheet(isPresented: $isConfirmAddItem){
                VStack{
                    Text("Are you sure?")
                        .font(.title3)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                }
                VStack(alignment: .leading){
                    
                    Text("Top")
                        .font(.caption)
                        .bold()
                    TextField("Top Temperature", text: $upperTemp)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Text("Bot")
                        .font(.caption)
                        .bold()
                    TextField("Lower Temperature", text: $lowerTemp)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Text("Moisture Content")
                        .font(.caption)
                        .bold()
                    TextField("Moisture Content", text: $mcnt)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Text("Remarks")
                        .font(.caption)
                        .bold()
                    TextField("Remarks", text: $comment)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .disabled(true)
                    
                    Button("Yes") {
                        addDataDryerHeader(noh: elapsedSinceStart, date: isoString, time: currentTime, upper: upperTemp, lower: lowerTemp, mc: mcnt, remarks: comment, sl: loggedUserid)
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        isConfirmAddItem = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                    
                }
                .padding(20)
                .presentationDetents([.fraction(0.8)])
            }
//          MARK: Sheet Confirm Internet
            .sheet(isPresented: $isConfirmInternet){
                VStack{
                    VStack(alignment: .center){
                        
                        Text("Required")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.red)
                        
                        Image(systemName: "wifi")
                            .resizable()
                            .frame(width: 60, height: 50)
                        
                    }
                    .padding(.bottom, 20)
                    
                    Button(action:{
                        
                        if NetworkMonitor.shared.isConnected {
                            // If naay internet
                            isConfirmInternet = false
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isReversal = true
                            }
                            
                        } else {
                            showAlertNoInternet = true
                        }
                        
                        
                    }){
                        Label("Check Internet Connection", systemImage: "")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button(action:{
                        isConfirmInternet = false
                    }){
                        Text("Close")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    
                    
                }
                .presentationDetents([.medium, .large])
                .padding(20)
                .presentationBackground(Color.white)
            }
//          MARK: Sheet for Shutoff
            .sheet(isPresented: $isShutOff){
                
                VStack{
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                    Text("Shut off")
                        .font(.title)
                        .padding(.bottom, 20)
                    VStack(alignment: .leading){
                        Text("Enter Shutoff MC")
                        TextField("", text: $shutoffmc)
                            .textFieldStyle(.roundedBorder)
                       
                        Button("Submit"){
                            getShutOff()
                        }
                        .buttonStyle(CustomButtonStyle())
                        
                    }
                }
                .padding(20)
                .presentationDetents([.medium])
            }
            
            
//          MARK: Sheet Reversal
            .sheet(isPresented: $isReversal){
                VStack{
                    
                    VStack(alignment: .center){
                        Text("Reversal")
                            .font(.title3)
                    }
                 
                    VStack(alignment: .leading){
                        Text("Top")
                            .font(.caption)
                            .bold()
                        TextField("Top Temperature", text: $upperTemp)
                            .padding(.bottom, 5)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: upperTemp) { newValue in
                                if let value = Double(newValue), value > 60 {
                                    upperTemp = "60"
                                }
                            }
                        
                        Text("Bot")
                            .font(.caption)
                            .bold()
                        TextField("Lower Temperature", text: $lowerTemp)
                            .padding(.bottom, 5)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: lowerTemp) { newValue in
                                if let value = Double(newValue), value > 60 {
                                    lowerTemp = "60"
                                }
                            }
                        
                        Text("Moisture Content")
                            .font(.caption)
                            .bold()
                        TextField("Moisture Content", text: $mcnt)
                            .padding(.bottom, 5)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Button("Save") {
                            
                            
//                                showAlertHaveInternet = true
//                                
                                updateReversal(dhidx: dhid)
//                                
                                addDataDryerHeader(noh: elapsedSinceStart, date: isoString, time: currentTime, upper: upperTemp, lower: lowerTemp, mc: mcnt, remarks: "Reversal", sl: loggedUserid)
                                
                                isReversal = false
                                
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Cancel") {
                            isReversal = false
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                .alert("Data Saved", isPresented: $showAlertHaveInternet) {
                    Button("OK", role: .cancel) { }
                } message: {
                   
                    Text("Drying data locally saved.")
                }
                
                .padding(20)
                .presentationDetents([.fraction(0.8)])
            }
//          MARK: Sheet Confirm Update Reversal
            .sheet(isPresented: $isConfirmUpdateReversal){
                Text("")
            }
//          MARK: Sheet Update Reversal No Internet
            .sheet(isPresented: $isUpdateReversalNoInternet){
                Text("Please connect to the internet")
            }
//          MARK: Sheet Add Item
            .sheet(isPresented: $isOpenAddItem){
                VStack{
                    Text("Add Item")
                        .font(.title3)
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                }
                VStack(alignment: .leading){
                    
                    Text("Top")
                        .font(.caption)
                        .bold()
                    TextField("Top Temperature", text: $upperTemp)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: upperTemp) { newValue in
                            if let value = Double(newValue), value > 60 {
                                upperTemp = "60"
                            }
                        }
                    
                    Text("Bot")
                        .font(.caption)
                        .bold()
                    TextField("Lower Temperature", text: $lowerTemp)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: lowerTemp) { newValue in
                            if let value = Double(newValue), value > 60 {
                                lowerTemp = "60"
                            }
                        }
                    
                    Text("Moisture Content")
                        .font(.caption)
                        .bold()
                    TextField("Moisture Content", text: $mcnt)
                        .padding(.bottom, 5)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Remarks")
                        .font(.caption)
                        .bold()
                    TextField("Remarks", text: $comment)
                        .padding(.bottom, 5)
                        .keyboardType(.default)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Save") {
                        isConfirmAddItem.toggle()
                        isOpenAddItem = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Cancel") {
                        isOpenAddItem = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    
                }
                .padding(20)
                .presentationDetents([.fraction(0.8)])
            }
//          MARK: Footer Buttons
            VStack{
                HStack {
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        
                        HStack(spacing: 12) {
                            
                            Button(action:{
                                isOpenAddItem.toggle()
                            }){
                                Label("Add Item", systemImage: "plus")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button(action:{
//                                isReversal = true
                                isConfirmInternet = true
                            }){
                                Label("Reversal", systemImage: "arrow.trianglehead.2.counterclockwise.rotate.90")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button(action:{
                                
                            }){
                                Label("Downtime", systemImage: "xmark.circle")
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Button(action:{
                                isShutOff = true
                            }){
                                Label("Shut Off", systemImage: "poweroff")
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            
                            if loggedUserid == "Dan" {
                                Button(action:{
                                   
//                                    nfcReader.beginScan(expectedToken: expectedToken)
                                    updateBinsToDry(context: modelContext)
                                    
                                }){
                                    Label("Remove", systemImage: "document.on.trash.fill")
                                }
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            
                            
                            
                            
                            
                        }
                        .padding(.horizontal)
                        
                    }
                    
                }
            }
            .padding()
           
            .navigationDestination(isPresented: $backToGrid) {
                DRHome()
            }
            .onChange(of: dryerHeaders) {
                print("🔥 DryerHeader changed!")
            }
            .onChange(of: nfcReader.lastPayload) { newValue in
                if newValue.lowercased().contains("dan") {
                    
//                    updateBinsToDry(context: modelContext)
                }
            }
        }
        .navigationTitle("Panel")
        
    }
    
    func sendReversal(){
        
    }
   
    func sendAllByDHID(dhidValue: String) {
        
        let descriptor = FetchDescriptor<DryerData>(
            predicate: #Predicate { data in
                data.dhid == dhidValue
            }
        )
        
        if let results = try? modelContext.fetch(descriptor) {
            DryerService.sendBatchToServer(dataList: results)
        }
    }
    
    func getShutOff(){
        
        if shutoffmc.isEmpty {
            print("MC is empty")
        }else{
            
            guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/getShutOff.php") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let body = "somc=\(shutoffmc)&binid=\(binid)&dhid=\(dhid)&rhid=\(rhid)&lotno=\(lotno)"
            request.httpBody = body.data(using: .utf8)
            
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let result = String(data: data, encoding: .utf8)
                    
                    print(result ?? "No data")
                    
                    if result == "Go" {
                        updateBinsToDry(context: modelContext)
                    }else if result == "Error"{
                        print(result)
                    }
                }
                
            }.resume()
            
        }
        
    }
    
    
    func formatToReadable(_ isoString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE MMM dd"
        
        if let date = inputFormatter.date(from: isoString) {
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    func validateTemps() {
        guard let upper = Double(upperTemp),
              let lower = Double(lowerTemp) else {
            errorMessage = "Please enter valid numbers."
            return
        }
        
//        if upper > 60 || lower > 60 {
//            errorMessage = "Temperature must not exceed 60°C."
//            return
//        }
//        
//        if lower > upper {
//            errorMessage = "Lower temp cannot be higher than Upper temp."
//            return
//        }
        
        errorMessage = ""
        print("Valid temps ✅ Upper: \(upper), Lower: \(lower)")
    }
    
    func sendNotificationAfter5Seconds() {
        
        let content = UNMutableNotificationContent()
        content.title = "Bin \(dhid)"
        content.body = "Add New Temeprature Now"
        content.sound = .defaultCritical
        
        // 🔥 custom data
        content.userInfo = ["screen": "Grid"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "dryer_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func addDataDryerHeader(noh: String, date: String, time: String, upper: String, lower: String, mc: String, remarks: String, sl: String){
        
        
        let newData = DryerData(dmid: UUID().uuidString, dhid: dhid, noh: elapsedSinceStart, date: date, time: time, upper: upper, lower: lower, boiler: "", mc: mc, remarks: remarks, status: "1", sl: loggedUserid, startstrtime: "")
        
        modelContext.insert(newData)
        
        print("Go")
        
        sendNotificationAfter5Seconds()
        
        isConfirmAddItem = false
        
        upperTemp = ""
        lowerTemp = ""
        mcnt = ""
        comment = ""
        
    }
    
    
    
    func updateReversal(dhidx: String){
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/updateReversal.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "dhid=\(dhidx)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "Done" {
                    print(result)
                }else if result == "Error"{
                    print(result)
                }
            }
            
        }.resume()
       
        
        
    }
    
    func updateBinsToDry(context: ModelContext){
        
        // ✅ Clean dhid (para iwas hidden spaces)
        let cleanDhid = dhid.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("🔍 Searching dhid:", cleanDhid)
        
        let descriptor = FetchDescriptor<DryerHeader>(
            predicate: #Predicate { item in
                item.dhid == cleanDhid
            }
        )
        
        do {
            let results = try context.fetch(descriptor)
            
            print("📦 Results found:", results.count)
            
            // 🔥 DEBUG: tan-awa tanan records
            for r in results {
                print("➡️ Found dhid:", r.dhid, "| status:", r.status)
            }
            
            if let item = results.first {
                
                print("🛠 Before update:", item.status)
                
                // ✅ UPDATE
                item.status = "4.1"
                
                print("🛠 After update:", item.status)
                
                // ✅ SAVE
                try context.save()
                
                print("✅ Updated successfully!")
                
                // UI actions
                DispatchQueue.main.async {
                    isShutOff = false
                    backToGrid = true
                }
                
            } else {
                print("❌ No matching record found")
            }
            
        } catch {
            print("❌ Error updating:", error)
        }
    }
    
    
}

final class NFCLoginReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published private(set) var statusMessage = "Ready to scan."
    @Published private(set) var isAuthenticated = false
    @Published private(set) var lastPayload = ""

    private var expectedToken = ""
    private var nfcSession: NFCNDEFReaderSession?

    func beginScan(expectedToken: String) {
        self.expectedToken = expectedToken.trimmingCharacters(in: .whitespacesAndNewlines)
        isAuthenticated = false
        lastPayload = ""
        statusMessage = "Hold your phone near the tag."

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your phone near the tag"
        nfcSession?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.statusMessage = "Session ended: \(error.localizedDescription)"
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first else {
            session.invalidate(errorMessage: "No NDEF records found.")
            DispatchQueue.main.async {
                self.statusMessage = "No NDEF records found."
            }
            return
        }

        let payloadString = payloadText(from: record) ?? ""
        let trimmedPayload = payloadString.trimmingCharacters(in: .whitespacesAndNewlines)
        let isMatch = !expectedToken.isEmpty && trimmedPayload == expectedToken

        DispatchQueue.main.async {
            self.lastPayload = trimmedPayload
            self.isAuthenticated = isMatch
            self.statusMessage = isMatch ? "Login success." : "Login failed."
        }

        session.alertMessage = isMatch ? "Login success." : "Login failed."
        session.invalidate()
    }

    private func payloadText(from record: NFCNDEFPayload) -> String? {
        let (text, _) = record.wellKnownTypeTextPayload()
        if let text {
            return text
        }

        if let url = record.wellKnownTypeURIPayload() {
            return url.absoluteString
        }

        return String(data: record.payload, encoding: .utf8)
    }
}


#Preview {
    Panel(dhid: "1034", startDate: "2024-01-01", rhid: "RH91543", binid: "99", lotno: "")
}
