//
//  ContentView.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel: AuthViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AuthViewModel())
    }

    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                HomeView(viewModel: viewModel)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
