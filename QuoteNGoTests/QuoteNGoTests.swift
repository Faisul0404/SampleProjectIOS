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
        var savedUser: User?
        let api = MockLoginAPI(result: .success(AuthLoginResponse(payload: makeUser(accessToken: "test-token"))))
        let viewModel = AuthViewModel(loginAPI: api.call, onSignIn: { savedUser = $0 })
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "test-token")
        XCTAssertEqual(api.callCount, 1)
        XCTAssertEqual(api.email, "person@example.com")
        XCTAssertEqual(api.password, "password")
        XCTAssertEqual(savedUser?.accessToken, "test-token")
        XCTAssertTrue(viewModel.password.isEmpty)
    }

    func testInvalidEmailDoesNotCallAPI() async {
        let api = MockLoginAPI(result: .success(AuthLoginResponse(payload: makeUser(accessToken: "unused"))))
        let viewModel = AuthViewModel(loginAPI: api.call)
        viewModel.userInputText = "invalid-email"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(api.callCount, 0)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testLoginFailureShowsMessage() async {
        let api = MockLoginAPI(result: .failure(TestError.rejected))
        let viewModel = AuthViewModel(loginAPI: api.call)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "wrong-password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Credentials were rejected.")
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLogoutClearsSession() async {
        let api = MockLoginAPI(result: .success(AuthLoginResponse(payload: makeUser(accessToken: "test-token"))))
        let viewModel = AuthViewModel(loginAPI: api.call)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"
        await viewModel.login()

        viewModel.logout()

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.accessToken)
        XCTAssertTrue(viewModel.userInputText.isEmpty)
    }

    func testLoginRequestMatchesSwaggerContract() throws {
        let service = AuthService(deviceID: "device-123", devicePushToken: "push-token")
        let credentials = LoginCredentials(email: "person@example.com", password: "a password")

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
        let api = MockLoginAPI(
            result: .failure(ErrorResponse.error(404, nil, TestError.rejected))
        )
        let viewModel = AuthViewModel(loginAPI: api.call)
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isSocialNotRegistered)
        XCTAssertEqual(viewModel.errorMessage, "Credentials were rejected.")
    }
}

private func makeUser(accessToken: String) -> User {
    User(
        _id: nil,
        uuid: nil,
        firstName: nil,
        lastName: nil,
        fullName: nil,
        email: nil,
        avatarUrl: nil,
        timezone: nil,
        countryCode: nil,
        phone: nil,
        emailVerifiedAt: nil,
        phoneVerifiedAt: nil,
        subscriptionLevel: nil,
        storeName: nil,
        isProfileCompleted: nil,
        isPackageSelected: nil,
        isPaymentMethods: nil,
        accessToken: accessToken
    )
}

@MainActor
private final class MockLoginAPI {
    let result: Result<AuthLoginResponse, Error>
    private(set) var callCount = 0
    private(set) var email: String?
    private(set) var password: String?

    init(result: Result<AuthLoginResponse, Error>) {
        self.result = result
    }

    func call(deviceId: String, deviceType: String, devicePushToken: String, email: String, password: String, accept: String) async throws -> AuthLoginResponse {
        callCount += 1
        self.email = email
        self.password = password
        return try result.get()
    }
}

private enum TestError: LocalizedError {
    case rejected

    var errorDescription: String? {
        "Credentials were rejected."
    }
}
