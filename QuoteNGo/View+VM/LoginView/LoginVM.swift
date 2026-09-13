//
//  LoginVM.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import Foundation
import Combine
import UIKit
import Alamofire

@MainActor
final class LoginVM: ObservableObject {
    @Published var userInputText = ""
    @Published private(set) var emailText = ""
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

    private let onSignIn: (User) -> Void
    private let networkCheck: () throws -> Void
    private(set) var accessToken: String?

    var isSocialNotRegistered: Bool {
        statusCode == 404
    }

    init() {
        self.onSignIn = { user in
            PersistenceController.shared.saveUserData(with: user)
        }
        self.networkCheck = {
            try Self.defaultCheckInternetConnection()
        }
    }

    init(
        onSignIn: @escaping (User) -> Void = { _ in },
        networkCheck: @escaping () throws -> Void = {}
    ) {
        self.onSignIn = onSignIn
        self.networkCheck = networkCheck
    }

    func checkInternetConnection() throws {
        try networkCheck()
    }

    static func defaultCheckInternetConnection() throws {
        if let reachability = NetworkReachabilityManager(), !reachability.isReachable {
            throw AppError.message("No internet connection. Please check your network settings.")
        }
    }

    func showInfoLogger(message: String) {
        print(message)
    }


    func signInCheck() throws {
        let input = userInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else {
            throw validationError(title: "Email Required", message: "Please enter email.")
        }
        guard !password.isEmpty else {
            throw validationError(title: "Password Required", message: "Please enter password.")
        }
        guard password.count >= 8 else {
            throw validationError(title: "Valid Password Required", message: "Password should contain a minimum of 8 characters.")
        }

        if Self.isValidEmail(input) {
            emailText = input
            return
        }
        throw validationError(title: "Invalid Email", message: "Please enter a valid email address.")
    }

    func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await proceedSignIn()
        } catch {
            statusCode = Self.statusCode(from: error)
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
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

    private var deviceID: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }

    private static func statusCode(from error: Error) -> Int? {
        guard case let ErrorResponse.error(statusCode, _, _) = error else { return nil }
        return statusCode
    }
}

private struct AuthValidationError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

extension LoginVM {

    @MainActor
    func proceedSignIn() async throws {
        errorMessage = nil
        statusCode = nil

        do {
            try checkInternetConnection()
            try signInCheck()

            let response = try await AsyncAPIWrapper.callAsync {
                AuthAPI.authPostLogin(
                    deviceId: ASP.shared.deviceId,
                    deviceType: ASP.shared.deviceType,
                    devicePushToken: AppUserDefaults.getFCMToken(),
                    email: self.emailText,
                    password: self.password,
                    accept: ASP.shared.accept,
                    completion: $0
                )
            }

            guard let payload = response.payload else {
                throw AppError.message("data not found")
            }

            onSignIn(payload)
            accessToken = payload.accessToken
            isAuthenticated = true
            password = ""

            self.showInfoLogger(message: "✅ access tocken: \(String(describing: PersistenceController.shared.accessToken))")
        } catch {
            throw error
        }
    }

    func logout() {
        accessToken = nil
        isAuthenticated = false
        userInputText = ""
        emailText = ""
        password = ""
        PersistenceController.shared.deleteUserData()
    }
}

