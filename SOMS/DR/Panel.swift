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

struct Panel: View {
    
//  Variables
    var dhid: String
    var startDate: String
    var rhid: String
    
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
    
//  Sheet Related
    @State private var isOpenAddItem: Bool = false
    @State private var isConfirmAddItem: Bool = false
    @State private var isEditItem: Bool = false
    @State private var isReversal: Bool = false
    @State private var isConfirmUpdateReversal: Bool = false
    @State private var isUpdateReversalNoInternet: Bool = false
    @State private var isConfirmInternet: Bool = false
    
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
//                        Text("\(dhid) - \(rhid)")
                    }
//                    VStack{
//                        Text("\(startDate)")
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
                        addDataDryerHeader(noh: elapsedSinceStart, date: isoString, time: currentTime, upper: upperTemp, lower: lowerTemp, mc: mcnt, remarks: comment, sl: "Dan")
                        
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
                                addDataDryerHeader(noh: elapsedSinceStart, date: isoString, time: currentTime, upper: upperTemp, lower: lowerTemp, mc: mcnt, remarks: "Reversal", sl: "Dan")
                                
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
                                
                            }){
                                Label("Shut Off", systemImage: "poweroff")
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            
                            
                        }
                        .padding(.horizontal)
                        
                    }
                    
                }
            }
            .padding()
           
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
        
        
        let newData = DryerData(dmid: UUID().uuidString, dhid: dhid, noh: elapsedSinceStart, date: date, time: time, upper: upper, lower: lower, boiler: "", mc: mc, remarks: remarks, status: "1", sl: sl, startstrtime: "")
        
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
    
    
}

#Preview {
    Panel(dhid: "1034", startDate: "2024-01-01", rhid: "")
}
