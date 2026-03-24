//
//  Login.swift
//  SOMS
//
//  Created by Dan XD on 2/27/26.
//

import SwiftUI
import SwiftData

struct Login: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errormessage: String = ""
    
    @State private var isLoggedIn = false
    
    @State private var goToGrid = false
    @State private var goToRegistration = false
    @State private var goToDR = false
    @State private var goToSL = false

    @AppStorage("loggedUsername") private var loggedUsername: String = ""
    @AppStorage("loggedUserid") private var loggedUserid: String = ""
    
    @Environment(\.modelContext) private var modelContext
    
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
                            VStack(spacing: 6) {
                                Text("SOMS")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                
                                Text("Stellar Operations Management System")
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
                        
                        if username == "rdomingo" && password == "12345" {
                            loggedUserid = "OP0001";
                            loggedUsername = "rdomingo";
                            goToDR = true
                        }else if username == "lgengoni" && password == "12345" {
                            loggedUserid = "OP0002";
                            loggedUsername = "lgengoni";
                            goToDR = true
                        }else if username == "etaberdo" && password == "12345" {
                            loggedUserid = "OP0003";
                            loggedUsername = "etaberdo";
                            goToDR = true
                        }else{
                            errormessage = "You are not eligible to use this app. Please contact the admin."
                        }
                        
//                        if let user = checkUser(username: username, password: password, context: modelContext) {
//                            
//                            loggedUsername = user.username
//                            loggedUserid = user.userid
//                            
//                            goToDR = true
//                            
//                            errormessage = user.user_level_id ?? "Error"
////                          isLoggedIn = true
//                            
//                        } else {
//                            
//                            errormessage = "You are not eligible to use this app. Please contact the admin."
//                        }
                        
                    } label: {
                        
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button(action:{
                        if username == "dan" && password == "12344"{
                            
                            loggedUsername = "dan"
                            loggedUserid = "Dan"
                            
                            goToDR = true
                        }
                        
                    }){
                        Text("Admin Login")
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
            }
            
            .navigationDestination(isPresented: $isLoggedIn) {
                ContentView()
            }
            
            .navigationDestination(isPresented: $goToGrid) {
//                Grid()
            }
            
            .navigationDestination(isPresented: $goToRegistration) {
                RegisterLocal()
            }
            
            .navigationDestination(isPresented: $goToDR) {
                DRHome()
            }
            
            .navigationDestination(isPresented: $goToSL) {
                SLHome()
            }
            
            
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    
    func checkUser(username: String, password: String, context: ModelContext) -> AppUser? {
        
        let u = username
        let p = password
        
        let predicate = #Predicate<AppUser> { user in
            user.username == u && user.password == p
        }
        
        var descriptor = FetchDescriptor<AppUser>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            return try context.fetch(descriptor).first
        } catch {
            print("Fetch error: \(error)")
            return nil
        }
    }
}

#Preview {
    Login()
}
