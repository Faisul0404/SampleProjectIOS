//
//  LoginVM.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import Foundation
import Combine
import UIKit

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

    private let loginAPI: LoginAPI
    private let onSignIn: (User) -> Void
    private(set) var accessToken: String?

    typealias LoginAPI = (_ deviceId: String, _ deviceType: String, _ devicePushToken: String, _ email: String, _ password: String, _ accept: String) async throws -> AuthLoginResponse

    var isLoggedIn: Bool {
        isAuthenticated
    }

    var isSocialNotRegistered: Bool {
        statusCode == 404
    }

    init() {
        loginAPI = Self.defaultLoginAPI
        onSignIn = { PersistenceController.shared.saveUserData(with: $0) }
    }

    init(loginAPI: @escaping LoginAPI, onSignIn: @escaping (User) -> Void = { _ in }) {
        self.loginAPI = loginAPI
        self.onSignIn = onSignIn
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

    func proceedSignIn() async throws {
        errorMessage = nil
        statusCode = nil
        try signInCheck()
        let response = try await loginAPI(deviceID, "APPLE", "", emailText, password, "application/json")
        guard let user = response.payload else {
            throw AuthValidationError(message: "Data not found.")
        }

        onSignIn(user)
        accessToken = user.accessToken
        isAuthenticated = true
        password = ""
    }

    func logout() {
        accessToken = nil
        isAuthenticated = false
        userInputText = ""
        emailText = ""
        password = ""
        PersistenceController.shared.deleteUserData()
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

    private static func defaultLoginAPI(
        deviceId: String,
        deviceType: String,
        devicePushToken: String,
        email: String,
        password: String,
        accept: String
    ) async throws -> AuthLoginResponse {
        try await AsyncAPIWrapper.callAsync {
            AuthAPI.authPostLogin(
                deviceId: deviceId,
                deviceType: deviceType,
                devicePushToken: devicePushToken,
                email: email,
                password: password,
                accept: accept,
                completion: $0
            )
        }
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

