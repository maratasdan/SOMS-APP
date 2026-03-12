//
//  Login.swift
//  SOMS
//
//  Created by Dan XD on 2/27/26.
//

import SwiftUI

struct Login: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGray6), Color(.white)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Welcome back")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
                
                Button(action: {}) {
                    Text("Login")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
            )
            .padding(20)
        }
    }
}

#Preview {
    Login()
}
