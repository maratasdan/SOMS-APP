//
//  ContentView.swift
//  SOMS
//
//  Created by Dan XD on 2/19/26.
//

import SwiftUI

struct ContentView: View {

    private enum SidebarItem: String, CaseIterable, Identifiable {
        case dryingPanel
        case confirm
        case schedules

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dryingPanel:
                return "Drying Panel"
            case .confirm:
                return "Confirm"
            case .schedules:
                return "Schedules"
            }
        }

        var systemImage: String {
            switch self {
            case .dryingPanel:
                return "flame.fill"
            case .confirm:
                return "circle.badge.checkmark"
            case .schedules:
                return "list.bullet.rectangle.portrait"
            }
        }
    }

    @State private var selection: SidebarItem? = .dryingPanel

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.systemImage)
                }
            }
            .navigationTitle("Home")
        } detail: {
            NavigationStack {
                detailView
                    .navigationTitle(selection?.title ?? "Home")
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .dryingPanel:
            Grid()
        case .confirm:
            Confirm()
        case .schedules:
            TPSchedules()
        case .none:
            Text("Select a section")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
