//
//  RegisterLocal.swift
//  SOMS
//
//  Created by Dan on 3/13/26.
//

import SwiftUI
import SwiftData

struct UserInfo: Codable, Identifiable {
    
    let id = UUID()
    var userid: String
    var username: String
    var password: String
    var user_level_id: String
    var status: String
    var first_name: String
    var last_name: String
    var gender: String?
    var position: String?
    
}

struct RegisterLocal: View {
    
    @State private var goToSave: Bool = false
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errormessage: String = ""
    
    @State private var userInfo: [UserInfo] = []
    
    @Environment(\.modelContext) private var context

    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                LinearGradient(
                    colors: [Color(.systemGray6), Color(.white)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    VStack(spacing: 6) {
                        HStack{
                            VStack{
                                NavigationLink(destination: Choose()) {
                                    Image(systemName: "arrow.left")
                                }
                            }
                            Spacer()
                            VStack{
                                Text("Registration")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                Text("Create your account locally")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Text(errormessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                            }
                            Spacer()
                            VStack{
                                
                            }
                        }
                    }
                    
                    VStack(spacing: 14) {
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            
                            TextField("Enter username", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            
                            SecureField("Enter password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                        
                    
                    Button {
                        
                        checkUserOnline(username: username, password: password)
                        
                    } label: {
                        
                        Text("Register")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
                )
                .padding(20)
                .onAppear {
                    if username.isEmpty {
                        username = ""
                    }
                    
                    if password.isEmpty {
                        password = ""
                    }
                }
            }
            
            .navigationDestination(isPresented: $goToSave) {
                SuccessReg()
            }
            
            .navigationBarBackButtonHidden(true)
        }
    }
    
    func checkUserOnline(username: String, password: String){
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/getUsers.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "type=1&username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                print(result ?? "No data")
                if result == "0" {
                    errormessage = "You are not eligible to use this app. Please contact the admin."
                }else if result == "1" {
                    getUserInformation()
                    errormessage = ""
                }
                
            }
        }.resume()
        
    }
    
    func fetchDRData() {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/getUsers.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([UserInfo].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.userInfo = decoded
                    }
                    
                } catch {
                    print("Error decoding:", error)
                }
            }
            
        }.resume()
    }
    
    func getUserInformation(){
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/getUsers.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "type=2&username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let result = String(data: data, encoding: .utf8)
                
                do {
                    let decoded = try JSONDecoder().decode([UserInfo].self, from: data)
                    
                    DispatchQueue.main.async {
                        self.userInfo = decoded
                    }
                    print(data ?? "No Data")
                    print("\(userInfo.first?.position ?? "No Data")")
                    saveDataLocaly()
                    
                } catch {
                    print("Error decoding:", error)
                }
                
                
            }
        }.resume()
        
    }
    
    func saveDataLocaly(){
        
        let userid = userInfo.first?.userid ?? "No Data"
        let username: String = self.username
        let password: String = userInfo.first?.password ?? "No Data"
        let user_level_id: String = userInfo.first?.user_level_id ?? "No Data"
        let status: String = userInfo.first?.status ?? "No Data"
        let first_name: String = userInfo.first?.first_name ?? "No Data"
        let last_name: String = userInfo.first?.last_name ?? "No Data"
        let position: String = userInfo.first?.position ?? "No Data"
        
        
        let item = AppUser(userid: userid, username: username, password: password, user_level_id: user_level_id, status: status, first_name: first_name, last_name: last_name, position: position)
        
        context.insert(item)
        
        print("Saved!")
        
        goToSave = true
        
    }
    
}

#Preview {
    RegisterLocal()
}
