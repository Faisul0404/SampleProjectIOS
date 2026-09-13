//
//  QuoteNGoTests.swift
//  QuoteNGoTests
//
//  Created by Developer on 2026-09-12.
//

import XCTest
@testable import QuoteNGo

@MainActor
final class QuoteNGoTests: XCTestCase {
    func testLoginSuccessAuthenticatesUser() async {
        let service = MockAuthService(result: .success(LoginResponse(token: "test-token")))
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "test-token")
        XCTAssertEqual(service.loginCallCount, 1)
        XCTAssertTrue(viewModel.password.isEmpty)
    }

    func testInvalidEmailOrPhoneDoesNotCallService() async {
        let service = MockAuthService(result: .success(LoginResponse(token: "unused")))
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "invalid-email"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email or phone number.")
        XCTAssertEqual(service.loginCallCount, 0)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testLoginFailureShowsMessage() async {
        let service = MockAuthService(result: .failure(TestError.rejected))
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "wrong-password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Credentials were rejected.")
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLogoutClearsSession() async {
        let service = MockAuthService(result: .success(LoginResponse(token: "test-token")))
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "0412345678"
        viewModel.password = "password"
        await viewModel.login()

        viewModel.logout()

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.accessToken)
        XCTAssertTrue(viewModel.userInputText.isEmpty)
        XCTAssertTrue(viewModel.phoneNumber.isEmpty)
    }

    func testPhoneLoginBuildsPhoneCredentials() async {
        let service = MockAuthService(result: .success(LoginResponse(token: "test-token")))
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "0412345678"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertEqual(service.credentials, LoginCredentials(email: nil, phone: "0412345678", password: "password"))
        XCTAssertTrue(viewModel.isAuthenticated)
    }

    func testLoginRequestMatchesSwaggerContract() throws {
        let service = AuthService(deviceID: "device-123", devicePushToken: "push-token")
        let credentials = LoginCredentials(email: "person@example.com", phone: nil, password: "a password")

        let request = service.makeLoginRequest(credentials: credentials)
        let body = try XCTUnwrap(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })

        XCTAssertEqual(request.url?.absoluteString, "https://quotengo.sandbox29.preview.cx/api/v1/login")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apiKey"), APIConstants.apiKey)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
        XCTAssertTrue(body.contains("device_id=device-123"))
        XCTAssertTrue(body.contains("device_type=APPLE"))
        XCTAssertTrue(body.contains("device_push_token=push-token"))
        XCTAssertTrue(body.contains("email=person@example.com"))
        XCTAssertTrue(body.contains("password=a%20password"))
        XCTAssertFalse(body.contains("phone="))
    }

    func testNotRegisteredStatusIsExposed() async {
        let service = MockAuthService(
            result: .failure(AuthServiceError.server(statusCode: 404, message: "Account not found."))
        )
        let viewModel = AuthViewModel(authService: service)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isSocialNotRegistered)
        XCTAssertEqual(viewModel.errorMessage, "Account not found.")
    }
}

@MainActor
private final class MockAuthService: AuthServicing {
    let result: Result<LoginResponse, Error>
    private(set) var loginCallCount = 0
    private(set) var credentials: LoginCredentials?

    init(result: Result<LoginResponse, Error>) {
        self.result = result
    }

    func login(credentials: LoginCredentials) async throws -> LoginResponse {
        loginCallCount += 1
        self.credentials = credentials
        return try result.get()
    }
}

private enum TestError: LocalizedError {
    case rejected

    var errorDescription: String? {
        "Credentials were rejected."
    }
}
