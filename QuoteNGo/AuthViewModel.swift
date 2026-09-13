import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var userInputText = ""
    @Published private(set) var emailText = ""
    @Published private(set) var phoneNumber = ""
    @Published var password = ""
    @Published var isSignUpViewActive = false
    @Published var isForgotPasswordViewActive = false
    @Published var showPassword = false
    @Published var isNotVerified = false
    @Published var verificationViewAction = false
    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false
    @Published private(set) var statusCode: Int?
    @Published var alertTitle = "Sign In Failed"
    @Published var errorMessage: String?

    private let authService: any AuthServicing
    private(set) var accessToken: String?

    var isSocialNotRegistered: Bool {
        statusCode == 404
    }

    init() {
        authService = AuthService()
    }

    init(authService: any AuthServicing) {
        self.authService = authService
    }

    func signInCheck() throws -> LoginCredentials {
        let input = userInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            throw validationError(title: "Email or Phone Number Required", message: "Please enter email or phone number.")
        }
        guard !password.isEmpty else {
            throw validationError(title: "Password Required", message: "Please enter password.")
        }
        guard password.count >= 8 else {
            throw validationError(title: "Valid Password Required", message: "Password should contain a minimum of 8 characters.")
        }

        if Self.isValidEmail(input) {
            emailText = input
            phoneNumber = ""
            return LoginCredentials(email: input, phone: nil, password: password)
        }
        if input.range(of: #"^0\d{9}$"#, options: .regularExpression) != nil {
            emailText = ""
            phoneNumber = input
            return LoginCredentials(email: nil, phone: input, password: password)
        }
        throw validationError(title: "Invalid Login", message: "Please enter a valid email or phone number.")
    }

    func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await proceedSignIn()
        } catch {
            statusCode = (error as? AuthServiceError)?.statusCode
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func proceedSignIn() async throws {
        errorMessage = nil
        statusCode = nil
        let credentials = try signInCheck()
        let response = try await authService.login(credentials: credentials)
        accessToken = response.token
        isAuthenticated = true
        password = ""
    }

    func logout() {
        accessToken = nil
        isAuthenticated = false
        userInputText = ""
        emailText = ""
        phoneNumber = ""
        password = ""
    }

    private func validationError(title: String, message: String) -> AuthValidationError {
        alertTitle = title
        return AuthValidationError(message: message)
    }

    private static func isValidEmail(_ value: String) -> Bool {
        value.range(
            of: #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#,
            options: [.regularExpression, .caseInsensitive]
        ) != nil
    }
}

private struct AuthValidationError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}