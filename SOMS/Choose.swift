//
//  Choose.swift
//  SOMS
//
//  Created by Dan on 3/16/26.
//

import SwiftUI

struct Choose: View {
    
    @State private var isToLogin: Bool = false
    @State private var isToReg: Bool = false
    
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
                        Text("SOMS")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Stellar Operations Management System")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Button {
                            isToLogin = true
                        } label: {
                            
                            Text("Login")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                           isToReg = true
                        } label: {
                            
                            Text("Register")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                            
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    
                    
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
                )
                .padding(20)
            }
            
            .navigationDestination(isPresented: $isToLogin) {
                Login()
            }
            
            .navigationDestination(isPresented: $isToReg) {
                RegisterLocal()
            }
            
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    Choose()
}
