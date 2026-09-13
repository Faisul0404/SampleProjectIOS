//
//  ContentView.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel: LoginVM

    init() {
        _viewModel = StateObject(wrappedValue: LoginVM())
    }

    init(viewModel: LoginVM) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                HomeView(viewModel: viewModel)
            } else {
                LoginView(vm: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
