import SwiftUI

struct LoginView: View {
    @ObservedObject var vm: LoginVM
    @State private var informationMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    logo
                        .padding(.top, 34)
                        .padding(.bottom, 34)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("me@example.com", text: $vm.userInputText)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .authFieldStyle()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        HStack {
                            Group {
                                if vm.showPassword {
                                    TextField("Password", text: $vm.password)
                                } else {
                                    SecureField("Password", text: $vm.password)
                                }
                            }
                            .textContentType(.password)

                            Button {
                                vm.showPassword.toggle()
                            } label: {
                                Image(systemName: vm.showPassword ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                            .accessibilityLabel(vm.showPassword ? "Hide password" : "Show password")
                        }
                        .authFieldStyle()
                    }
                    .padding(.top, 16)

                    Button("Forgot Password?") {
                        vm.isForgotPasswordViewActive = true
                        informationMessage = "Connect this action to your forgot-password flow."
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 20)

                    Button {
                        Task { await vm.login() }
                    } label: {
                        Group {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Sign In").fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .disabled(vm.isLoading)

                    Text("Or continue with")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top, 36)
                        .padding(.bottom, 20)

                    HStack(spacing: 16) {
                        socialButton(systemName: "apple.logo", color: .black, name: "Apple")
                        socialButton(systemName: "g.circle.fill", color: .red, name: "Google")
                        socialButton(systemName: "f.circle.fill", color: .blue, name: "Facebook")
                    }

                    Spacer(minLength: 48)

                    HStack(spacing: 4) {
                        Text("Don’t have an account?")
                        Button("Sign Up") {
                            vm.isSignUpViewActive = true
                            informationMessage = "Connect this action to your sign-up flow."
                        }
                        .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 560, minHeight: 680)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(vm.isLoading)
        }
        .alert(vm.alertTitle, isPresented: errorAlertBinding) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "Please try again.")
        }
        .alert("Coming Soon", isPresented: informationAlertBinding) {
            Button("OK", role: .cancel) { informationMessage = nil }
        } message: {
            Text(informationMessage ?? "")
        }
    }

    private var logo: some View {
        VStack(spacing: 10) {
            Image(systemName: "quote.opening")
                .font(.system(size: 52, weight: .bold))
            Text("QuoteNGo")
                .font(.system(size: 30, weight: .bold, design: .rounded))
        }
        .accessibilityElement(children: .combine)
    }

    private func socialButton(systemName: String, color: Color, name: String) -> some View {
        Button {
            informationMessage = "Connect the \(name) sign-in provider."
        } label: {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color, in: RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityLabel("Continue with \(name)")
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )
    }

    private var informationAlertBinding: Binding<Bool> {
        Binding(
            get: { informationMessage != nil },
            set: { if !$0 { informationMessage = nil } }
        )
    }
}

private extension View {
    func authFieldStyle() -> some View {
        padding(.horizontal, 14)
            .frame(minHeight: 50)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.separator), lineWidth: 0.5)
            }
    }
}

#Preview {
    LoginView(vm: LoginVM())
}
