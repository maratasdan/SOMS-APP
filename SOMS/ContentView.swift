//
//  ContentView.swift
//  SOMS
//
//  Created by Dan XD on 2/19/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    private enum SectionItem: String, CaseIterable, Identifiable {
        case dryingPanel
        case confirm
        case schedules

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dryingPanel:
                return "Drying List"
            case .confirm:
                return "Confirm"
            case .schedules:
                return "Schedules"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    @AppStorage("loggedUsername") private var loggedUsername: String = ""

    @Query private var users: [AppUser]

    @State private var selection: SectionItem = .dryingPanel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                segmentedControl
                contentView
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    private var loggedUserDisplay: String {
        let trimmedUsername = loggedUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        if let user = users.first(where: { $0.username == trimmedUsername }) {
            let fullName = "\(user.first_name) \(user.last_name)"
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return fullName.isEmpty ? user.username : fullName
        }

        return trimmedUsername.isEmpty ? "Unknown User" : trimmedUsername
    }

    private var segmentedControl: some View {
        Picker("Section", selection: $selection) {
            ForEach(SectionItem.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private var contentView: some View {
        switch selection {
        case .dryingPanel:
            Grid()
        case .confirm:
            Confirm()
        case .schedules:
            TPSchedules()
        }
    }

    private var headerView: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle")
                .font(.title2)

            Text(loggedUserDisplay)
                .lineLimit(1)
                .truncationMode(.tail)
                .font(.headline)

            Spacer()

            Button("Logout") {
                loggedUsername = ""
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}
