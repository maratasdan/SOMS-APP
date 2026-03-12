//
//  ViewList.swift
//  SOMS
//
//  Created by Dan XD on 3/2/26.
//

import SwiftUI

struct ViewSpecificList: Codable, Identifiable {
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

struct ViewSpecificData: Codable, Identifiable {
    let id = UUID()
    var listid: String?
    var actellic: String?
    var actellicwater: String?
    var thiram: String?
    var thiramwater: String?
    var yellowPol: String?
    var thiramyellwater: String?
    var operatorName: String?
    var signature1: String?
    var preparedName: String?
    var signature2: String?
    var validatedName: String?
    var signature3: String?
    
    enum CodingKeys: String, CodingKey {
        case listid, actellic, actellicwater, thiram, thiramwater, yellowPol, thiramyellwater, operatorName, signature1, preparedName, signature2, validatedName, signature3
    }
    
}


struct ViewList: View {
    
    let tplid: String
    
    @State private var countSig: Int = 0
    
    @State private var viewSpecificList: [ViewSpecificList] = []
    @State private var viewSpecificData: [ViewSpecificData] = []
    
    @State private var isOpenFinalConf: Bool = false
    @State private var isOpenActualData: Bool = false
    @State private var isOpenActualData2: Bool = false
    @State private var refreshTrigger = false
    @State private var goToRefreshPage = false
    @State private var firstSig = false
    @State private var goBackToList = false
    
    @State private var strokes: [[CGPoint]] = []
    @State private var currentStroke: [CGPoint] = []
    
//  MARK: Input Texts
    
    @State private var inputTypeActellic: String = ""
    @State private var inputTypeActellicWater: String = ""
    
    @State private var inputTypeThiram: String = ""
    @State private var inputTypeThiramWater: String = ""
    
    @State private var inputTypeYellowPolymer: String = ""
    @State private var inputTypeYellowPolymerWater: String = ""
    
    @State private var name1: String = ""
    @State private var name2: String = ""
    @State private var name3: String = ""
    
    @State private var sigpvar: String = ""
    
//  MARK: Variables for formula
    
    @State private var refreshID = UUID()
    
    @State private var batchqty: String = "0.000"
    
    @State private var actellicInput: Double = 0.000
    @State private var actellicInputWater: Double = 0.000
    
    @State private var actellicInputVal: Double = 0.000
    @State private var actellicInputWaterVal: Double = 0.000
    
    var body: some View {
        
        let batchkl = Double(viewSpecificList.first?.quantity ?? "0") ?? 0.0
        
        let actellicmr = 0.020
        let thirammr = 1.000
        let yellowPolymer = 2.000

//      Actellic Cal
        let actellictotal = (batchkl * actellicmr) / 1000
        let actellictotalwater = (batchkl * 4) / 1000
        
        let actellicsum = Double(viewSpecificData.first?.actellic ?? "0.00") ?? 0.00
        let actellicandwatersumwater = Double(viewSpecificData.first?.actellicwater ?? "0.00") ?? 0.00
        
        let actellicandwatersumfinal = actellicsum + actellicandwatersumwater
        
//      Thiram Cal
        let thiramtotal = (batchkl * thirammr) / 1000
        let thiramtotalwater = (batchkl * 5) / 1000
        
        let thiramsum = Double(viewSpecificData.first?.thiram ?? "0.00") ?? 0.00
        let thiramandwatersumwater = Double(viewSpecificData.first?.thiramwater ?? "0.00") ?? 0.00
        
        let thiramandwatersumfinal = thiramsum + thiramandwatersumwater

//      Yellow Polymer
        let yellowpolymertotal = (batchkl * yellowPolymer) / 1000
        let yellowpolymertotalwater = (batchkl * 5) / 1000
        
        let yellowpolymersum = Double(viewSpecificData.first?.yellowPol ?? "0.00") ?? 0.00
        let yellowpolymerandwatersumwater = Double(viewSpecificData.first?.yellowPol ?? "0.00" ) ?? 0.00
        
        let thiramyellwater = Double(viewSpecificData.first?.thiramyellwater ?? "0.00") ?? 0.00
        
        let thiramyellowwatersum = yellowpolymersum + thiramsum + thiramyellwater
        
        let columns = [
           GridItem(.flexible(), spacing: 0),
           GridItem(.flexible(), spacing: 0),
           GridItem(.flexible(), spacing: 0)
       ]
        
        NavigationStack {
            ScrollView(.vertical, showsIndicators: true) {
            VStack{
// MARK: HEADER
                VStack(alignment: .leading){
                    HStack{
                        NavigationLink(destination: TOSchedList(refno: viewSpecificList.first?.refno ?? "")){
                            Image(systemName: "arrow.left")
                                .resizable()
                                .frame(width: 30, height: 30)
                                
                        }
                        Spacer()
                        NavigationLink(destination: TOSchedList(refno: viewSpecificList.first?.refno ?? "")){
                            
                                
                        }
                        
                        Button(action: {
                            isOpenFinalConf = true
                        }){
                            Image(systemName: "checkmark.circle")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                    }
                    .padding(.bottom, 20)
                    HStack{
                        VStack(alignment: .leading){
                            Text("Com 500 Batch No:")
                                .font(.title2)
                            Text(viewSpecificList.first?.com500_batch ?? "")
                                .bold()
                                .font(.title)
                        }
                        Spacer()
                        VStack(alignment: .leading){
                            Text("Quantity:")
                                .font(.title2)
                            Text(viewSpecificList.first?.quantity ?? "")
                                .bold()
                                .font(.title)
                        }
                    }
                    .padding(.bottom, 20)
                    
//                    HStack{
//                        VStack(alignment: .leading){
//                            Text("Date:")
//                            Text(viewSpecificList.first?.created_at ?? "")
//                                .bold()
//                        }
//                        Spacer()
//
//                    }
//                    .font(.title2)
                }
// MARK: HEADER END
                Divider()
                    .padding(.bottom, 10)
                VStack(alignment: .leading){
// MARK: Rice Recipe
                    VStack(alignment: .center){
                        Text("Rice Chemical Recipe Computations")
                            .font(.title2)
                            .padding(.bottom, 10)
                            .bold()
                        
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                
                                VStack(alignment: .leading){
                                    Text("Chemicals")
                                    .bold()
                                    .font(.title2)
                                    Divider()
                                    Text("Actellic")
                                    Divider()
                                    Text("Thiram")
                                    Divider()
                                    Text("Yellow Polymer")
                                    
                                }
                                .padding(.trailing, 20)
                                
                                VStack(alignment: .leading){
                                    Text("Relative Density")
                                    .bold()
                                    .font(.title2)
                                    Divider()
                                    Text("1.020")
                                    Divider()
                                    Text("0.670")
                                    Divider()
                                    Text("1.190")
                                    
                                }
                                .padding(.trailing, 20)
                                
                                VStack(alignment: .leading){
                                    Text("Chemical Recipe")
                                    .bold()
                                    .font(.title2)
                                    Divider()
                                    Text("0.02")
                                    Divider()
                                    Text("1.020")
                                    Divider()
                                    Text("1.68")
                                    
                                }
                                .padding(.trailing, 20)

                                VStack(alignment: .leading){
                                    Text("Water/Qty(g)")
                                    .bold()
                                    .font(.title2)
                                    Divider()
                                    Text("4")
                                    Divider()
                                    Text("5")
                                    Divider()
                                    Text("5")
                                    
                                }
                                .padding(.trailing, 20)
                                
                                VStack(alignment: .leading){
                                    Text("Mass Balance Recipe")
                                    .bold()
                                    .font(.title2)
                                    Divider()
                                    Text("0.020")
                                    Divider()
                                    Text("1.000")
                                    Divider()
                                    Text("2.000")
                                    
                                }
                                .padding(.trailing, 20)
                                
                            }
                        }
                        .id(refreshID)
                    }
                    
                    
// MARK: Rice Recipe End
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 50)
// MARK: Actellic Start
                    VStack (alignment: .leading){
                        Text("Computations")
                            .font(.title2)
                            .padding(.bottom, 10)
                            .bold()
                        HStack{
                            
                            VStack(alignment: .leading){
                                Text("Chemicals")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                Text("Actellic")
                                Divider()
                                Text("Water")
                                Divider()
                                Text("Total")
                                    .italic()
                                    
                            }
                            .padding(.trailing, 20)
                            
                            VStack(alignment: .leading){
                                Text("Mass Weight")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", actellictotal))
                                    Spacer()
                                    Text("KILO")
                                }
                                .background(Color(hex: "#fbff35"))
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", actellictotalwater))
                                    Spacer()
                                    Text("KILO")
                                }
                                .background(Color(hex: "#fbff35"))
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", actellictotal + actellictotalwater))
                                    Spacer()
                                    Text("KILO")
                                }
                                .bold()
                                .italic()
                            }
                            .padding(.trailing, 20)
                            
                            VStack(alignment: .leading){
                                Text("Actual")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                HStack{
                                    if actellicInput < actellictotal {
                                        Text("\(viewSpecificData.first?.actellic ?? "0.000")")
//                                            .foregroundStyle(Color.red)
                                            .bold()
                                    }else{
                                        Text("\(viewSpecificData.first?.actellic ?? "0.000")")
                                            .bold()
                                    }
                                    
                                    Spacer()
                                    Button(action: {
                                        isOpenActualData = true
                                    }){
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                Divider()
                                HStack{
                                    if actellicInputWater < actellictotalwater {
                                        Text("\(viewSpecificData.first?.actellicwater ?? "0.000")")
//                                            .foregroundStyle(Color.red)
                                            .bold()
                                    }else{
                                        Text("\(viewSpecificData.first?.actellicwater ?? "0.000")")
                                            .bold()
                                    }
                                    Spacer()
                                    Button(action: {
                                        isOpenActualData = true
                                    }){
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", actellicandwatersumfinal))
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding(.trailing, 20)
                            
                            
                        }
                    }
                    .sheet(isPresented: $isOpenActualData){
                        VStack{
                            VStack(alignment: .center){
                                VStack{
                                    Image(systemName: "scalemass")
                                        .font(.system(size: 40))
                                }
                                VStack(alignment: .leading){
                                    Text("Enter Actellic Value")
                                    TextField(text: $inputTypeActellic){
                                        Text("\(viewSpecificData.first?.actellic ?? "0.000")")
                                            .fontDesign(.monospaced)
                                            .bold()
                                    }
                                    .multilineTextAlignment(.leading)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                    
                                }
                                .padding(.top, 10)
                                VStack(alignment: .leading){
                                    Text("Enter Water Value")
                                    TextField(text: $inputTypeActellicWater){
                                        Text("\(viewSpecificData.first?.actellicwater ?? "0.000")")
                                            .fontDesign(.monospaced)
                                            .bold()
                                    }
                                    .multilineTextAlignment(.leading)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                                }
                                .padding(.top, 10)
                                
                                VStack{
                                    Button(action: {
                                        saveTPDataActellic(val1: inputTypeActellic, val2: inputTypeActellicWater)
                                    }){
                                        Text("Save")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 35)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .buttonBorderShape(.roundedRectangle)
                                    
                                    Button(action: {
                                        isOpenActualData = false
                                    }){
                                        Text("Close")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 35)
                                    .foregroundColor(.red)
                                }
                                .padding(.top, 10)
                                
                            }
                        }
                        .padding(20)
                        .presentationDetents([.medium, .large])
                    }
                    
                    Divider()
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                    
// MARK: Actellic End
                    
// MARK: Thiram and Yellow Polymer
                    VStack (alignment: .leading){
                           
                        HStack{
                            
                            VStack(alignment: .leading){
                                Text("Chemicals")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                Text("Thiram")
                                Divider()
                                Text("Yellow Polymer")
                                Divider()
                                Text("Water")
                                Divider()
                                Text("Total")
                                    .italic()
                                    
                            }
                            .padding(.trailing, 20)
                            
                            VStack(alignment: .leading){
                                Text("Mass Weight")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", thiramtotal))
                                    Spacer()
                                    Text("KILO")
                                }
                                .background(Color(hex: "#fbff35"))
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", yellowpolymertotal))
                                    Spacer()
                                    Text("KILO")
                                }
                                .background(Color(hex: "#fbff35"))
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", thiramtotalwater))
                                    Spacer()
                                    Text("KILO")
                                }
                                .background(Color(hex: "#fbff35"))
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", thiramtotalwater + thiramtotal + yellowpolymertotal))
                                    Spacer()
                                    Text("KILO")
                                }
                                .bold()
                                .italic()
                            }
                            .padding(.trailing, 20)
                            
                            VStack(alignment: .leading){
                                Text("Actual")
                                    .font(.title2)
                                    .bold()
                                Divider()
                                HStack{
                                    Text("\(viewSpecificData.first?.thiram ?? "0.000")")
                                    
                                    Spacer()
                                    Button(action: {
                                        isOpenActualData2 = true
                                    }){
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                Divider()
                                HStack{
                                    Text("\(viewSpecificData.first?.yellowPol ?? "0.000")")
                                    Spacer()
                                    Button(action: {
                                        isOpenActualData2 = true
                                    }){
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                Divider()
                                HStack{
                                    Text("\(viewSpecificData.first?.thiramyellwater ?? "0.000")")
                                    Spacer()
                                    Button(action: {
                                        isOpenActualData2 = true
                                    }){
                                        Image(systemName: "plus.circle")
                                    }
                                }
                                Divider()
                                HStack{
                                    Text(String(format: "%.3f", thiramyellowwatersum))
                                        .bold()
                                    Spacer()
                                }
                            }
                            .padding(.trailing, 20)
                            
                            
                        }
                    }
                    
                }
                .sheet(isPresented: $isOpenActualData2){
                    VStack{
                        VStack(alignment: .center){
                            VStack{
                                Image(systemName: "scalemass")
                                    .font(.system(size: 40))
                            }
                            VStack(alignment: .leading){
                                Text("Enter Thiram Value")
                                TextField(text: $inputTypeThiram){
                                    Text("\(viewSpecificData.first?.thiram ?? "0.000")")
                                        .fontDesign(.monospaced)
                                        .bold()
                                }
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                
                            }
                            .padding(.top, 10)
                            VStack(alignment: .leading){
                                Text("Enter Actellic Value")
                                TextField(text: $inputTypeYellowPolymer){
                                    Text("\(viewSpecificData.first?.yellowPol ?? "0.000")")
                                        .fontDesign(.monospaced)
                                        .bold()
                                }
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                                
                            }
                            .padding(.top, 10)
                            VStack(alignment: .leading){
                                Text("Enter Water Value")
                                TextField(text: $inputTypeThiramWater){
                                    Text("\(viewSpecificData.first?.thiramyellwater ?? "0.000")")
                                        .fontDesign(.monospaced)
                                        .bold()
                                }
                                .multilineTextAlignment(.leading)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            }
                            .padding(.top, 10)
                            
                            VStack{
                                Button(action: {
//                                    saveTPDataActellic(val1: inputTypeActellic, val2: inputTypeActellicWater)
                                    saveTPDataActellic2(
                                        val1: inputTypeThiram,
                                        val2: inputTypeYellowPolymer,
                                        val3: inputTypeThiramWater
                                    )
                                }){
                                    Text("Save")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 35)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .buttonBorderShape(.roundedRectangle)
                                
                                Button(action: {
                                    isOpenActualData2 = false
                                }){
                                    Text("Close")
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 35)
                                .foregroundColor(.red)
                            }
                            .padding(.top, 10)
                            
                        }
                        .presentationDetents([.fraction(2)])
                    }
                    .padding(20)
                    
                }
                
//            MARK: Final Confirmation
                
                .sheet(isPresented: $isOpenFinalConf){
                    VStack{
//                        Text("\(viewSpecificList.first?.tplid ?? "" ) + \(tplid)")
                        Text("Are you sure?")
                            .padding(.bottom, 20)
                        
                        Button(action:{
                            updateSaveTP(tplid: tplid)
                        }){
                            Text("Yes")
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(Color.blue)
                                .cornerRadius(5)
                                .foregroundStyle(Color.white)
                        }
                        
                        Button(action:{
                            isOpenFinalConf = false
                        }){
                            Text("No")
                                .foregroundStyle(Color.red)
                        }
                    }
                    .presentationDetents([.fraction(0.4)])
                    .padding(20)
                }
                
//              MARK: Thiram and Yellow Polymer End
                
                Spacer()
//              MARK: Footer
                ZStack{
                    
                    VStack(alignment: .trailing){
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            
                            VStack(alignment: .center){
                                AsyncImage(url: URL(string: "https://stellarseedscorp.org/system/app/T%26P/uploads/\(viewSpecificData.first?.signature1 ?? "")")) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.bottom, -50)
                                
                                Text("\(viewSpecificData.first?.operatorName ?? "Please Input Name")")
                                    .bold()
                                    .underline()
                                
                                
                                
                                Text("Operator")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .onTapGesture {
                                firstSig = true
                                sigpvar = "1"
                            }
                            
                            
                            VStack(alignment: .center){
                                AsyncImage(url: URL(string: "https://stellarseedscorp.org/system/app/T%26P/uploads/\(viewSpecificData.first?.signature2 ?? "")")) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.bottom, -50)
                                
                                Text("\(viewSpecificData.first?.preparedName ?? "Please Input Name")")
                                    .bold()
                                
                                    .underline()
                                Text("Prepared By")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .onTapGesture {
                                firstSig = true
                                sigpvar = "2"
                            }
                            
                            
                            VStack(alignment: .center){
                                AsyncImage(url: URL(string: "https://stellarseedscorp.org/system/app/T%26P/uploads/\(viewSpecificData.first?.signature3 ?? "")")) { image in
                                    image.resizable().scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .padding(.bottom, -50)
                                
                                Text("\(viewSpecificData.first?.validatedName ?? "Please Input Name")")
                                    .bold()
                                
                                    .underline()
                                Text("Validated By")
                            }
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.white)
                            .onTapGesture {
                                firstSig = true
                                sigpvar = "3"
                            }
                            
                        }
                        
                    }
                    //    MARK: Sheet for Signature
                    .sheet(isPresented: $firstSig){
                        
                        VStack {
                            VStack{
                                Text("\(sigpvar)")
                                TextField(text: $name1){
                                    Text("Name")
                                        .fontDesign(.monospaced)
                                        .bold()
                                }
                                .multilineTextAlignment(.leading)
                                .textFieldStyle(.roundedBorder)
                                .border(Color.gray, width: 1)
                                .frame(maxWidth: 400)
                            }
                            .padding(.bottom, 10)
                            ZStack {
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .textFieldStyle(.roundedBorder)
                                
                                Path { path in
                                    
                                    for stroke in strokes {
                                        guard let first = stroke.first else { continue }
                                        path.move(to: first)
                                        
                                        for point in stroke.dropFirst() {
                                            path.addLine(to: point)
                                        }
                                    }
                                    
                                    if let first = currentStroke.first {
                                        path.move(to: first)
                                        for point in currentStroke.dropFirst() {
                                            path.addLine(to: point)
                                        }
                                    }
                                }
                                .stroke(Color.black, lineWidth: 2)
                                
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        currentStroke.append(value.location)
                                    }
                                    .onEnded { _ in
                                        strokes.append(currentStroke)
                                        currentStroke = []
                                    }
                            )
                            .frame(width: 400, height: 200)
                            .border(Color.gray, width: 1)
                            
                            VStack {
                                
                                if strokes.isEmpty && currentStroke.isEmpty || name1 == "" {
                                    Button(action: {
                                        saveAndUploadSignature()
                                    }){
                                        Text("Save & Upload")
                                            .foregroundStyle(Color.white)
                                    }
                                    .frame(width: 400, height: 40)
                                    .background(Color.gray)
                                    .cornerRadius(5)
                                    .disabled(true)
                                    
                                    Button("Clear") {
                                        strokes = []
                                        currentStroke = []
                                    }
                                    
                                }else{
                                    Button(action: {
                                        saveAndUploadSignature()
                                    }){
                                        Text("Save & Upload")
                                            .foregroundStyle(Color.white)
                                    }
                                    .frame(width: 400, height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(5)
                                    
                                    Button("Clear") {
                                        strokes = []
                                        currentStroke = []
                                    }
                                }
                                
                                
                                
                            }
                            .padding()
                        }
                        .padding()
                    }
                    
                }
                }
                
                NavigationLink("", destination: RefreshPage(tplid: tplid), isActive: $goToRefreshPage)
                    .hidden()
                
                NavigationLink("", destination: TOSchedList(refno: viewSpecificList.first?.refno ?? ""), isActive: $goBackToList)
                    .hidden()
                
                
            }
            .onAppear {
                fetchTPData()
                fetchTPSpecificData()
            }
            .padding(20)
        }
        .navigationTitle("Rice Chemical Recipe Computations")
        .navigationBarBackButtonHidden(true)
    }
    
    func updateSaveTP(tplid: String){
        
        print("\(tplid)")
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/saveDataTP.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "tplid=\(viewSpecificList.first?.tplid ?? "")"
        request.httpBody = body.data(using: .utf8)
        
        
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "Go" {
                    isOpenFinalConf = false
                    goBackToList = true
                }else{

                }
                
            }
        }.resume()
        
    }
    
    func saveTPDataActellic2(val1: String, val2: String, val3: String){
       
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/saveActualData2.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "listid=\(tplid)&thiram=\(val1)&yellowpol=\(val2)&water=\(val3)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "saved" {
                    isOpenActualData2 = false
                    inputTypeActellic = "0"
                    inputTypeActellicWater = "0"
                    refreshID = UUID()
                    
                    goToRefreshPage = true
                    
                }
                
            }
        }.resume()
        
    }
    
    func saveTPDataActellic(val1: String, val2: String){
       
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/saveActualData.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "listid=\(tplid)&actellic=\(val1)&actellicwater=\(val2)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                
                if result == "saved" {
                    isOpenActualData = false
                    inputTypeActellic = "0"
                    inputTypeActellicWater = "0"
                    refreshID = UUID()
                    
                    goToRefreshPage = true
                    
                }
                
//                if result == "Done" {
//                    goToAdopt = true
//                    srhid = rhidx
//                    sdhid = dhidx
//                    
//                }else if result == "Error"{
//                    alertError = true
//                }
            }
        }.resume()
        
    }
    
    func fetchTPData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/getSpecificList.php?tplid=\(tplid)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([ViewSpecificList].self, from: data)
                    DispatchQueue.main.async {
                        self.viewSpecificList = decoded
                    }
                } catch {
                    print("Error decoding:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
    
    func fetchTPSpecificData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/getSpecificListData.php?tplid=\(tplid)") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                
                print(data)
                
                do {
                    let decoded = try JSONDecoder().decode([ViewSpecificData].self, from: data)
                    DispatchQueue.main.async {
                        self.viewSpecificData = decoded
                    }
                } catch {
                    print("Error decoding:", error)
                }
            } else if let error = error {
                print("Network error:", error)
            }
        }.resume()
    }
    
//  MARK: Signature Functions
    
    func saveAndUploadSignature() {
        let image = pointsToImage()
        if let data = image.pngData() {
            uploadSignature(data: data, username: name1, sigp: sigpvar)
        }
    }
    
    func pointsToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 200))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: 400, height: 200))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.setLineCap(.round)
            
            for stroke in strokes {
                guard let first = stroke.first else { continue }
                
                ctx.cgContext.move(to: first)
                
                for point in stroke.dropFirst() {
                    ctx.cgContext.addLine(to: point)
                }
            }
            
            ctx.cgContext.strokePath()
        }
    }
    
    func uploadSignature(data: Data, username: String, sigp: String) {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/uploadSig.php?name1=\(name1)&com500=\(viewSpecificList.first?.com500_batch ?? "")&tplid=\(tplid)&sigp=\(sigp)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = "signature.png"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: body) { responseData, _, error in
            if let error = error {
                print("Upload error: \(error)")
            } else {
                
                goToRefreshPage = true
                firstSig = false
                print("Signature uploaded successfully!")
                
                
            }
        }.resume()
    }
    
}

#Preview {
    ViewList(tplid: "97")
}
