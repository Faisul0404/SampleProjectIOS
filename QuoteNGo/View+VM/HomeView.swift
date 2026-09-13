import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Image(systemName: "house.fill")
                    .font(.system(size: 54))
                Text("Welcome to QuoteNGo")
                    .font(.title2.bold())
                Text("You are signed in.")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}