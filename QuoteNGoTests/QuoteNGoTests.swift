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
    private var originalFactory: RequestBuilderFactory!

    override func setUp() {
        super.setUp()
        originalFactory = SwaggerClientAPI.requestBuilderFactory
        SwaggerClientAPI.requestBuilderFactory = MockRequestBuilderFactory()
    }

    override func tearDown() {
        SwaggerClientAPI.requestBuilderFactory = originalFactory
        MockLoginAPI.reset()
        super.tearDown()
    }

    func testLoginSuccessAuthenticatesUser() async {
        let mock = MockLoginAPI.mock(
            result: .success(AuthLoginResponse(payload: makeUser(accessToken: "test-token")))
        )
        let viewModel = LoginVM()
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.accessToken, "test-token")
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(mock.email, "person@example.com")
        XCTAssertEqual(mock.password, "password")
        XCTAssertTrue(viewModel.password.isEmpty)
    }

    func testInvalidEmailDoesNotCallAPI() async {
        let mock = MockLoginAPI.mock(
            result: .success(AuthLoginResponse(payload: makeUser(accessToken: "unused")))
        )
        let viewModel = LoginVM()
        viewModel.userInputText = "invalid-email"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertEqual(mock.callCount, 0)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testLoginFailureShowsMessage() async {
        let mock = MockLoginAPI.mock(
            result: .failure(ErrorResponse.error(401, nil, TestError.rejected))
        )
        let viewModel = LoginVM()
        viewModel.userInputText = "person@example.com"
        viewModel.password = "wrong-password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Credentials were rejected.")
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLogoutClearsSession() async {
        _ = MockLoginAPI.mock(
            result: .success(AuthLoginResponse(payload: makeUser(accessToken: "test-token")))
        )
        let viewModel = LoginVM()
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
        let mock = MockLoginAPI.mock(
            result: .failure(ErrorResponse.error(404, nil, TestError.rejected))
        )
        let viewModel = LoginVM()
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertTrue(viewModel.isSocialNotRegistered)
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertEqual(viewModel.errorMessage, "Credentials were rejected.")
    }

    func testNoInternetConnectionThrowsAppError() async {
        let mock = MockLoginAPI.mock(
            result: .success(AuthLoginResponse(payload: makeUser(accessToken: "unused")))
        )
        let viewModel = LoginVM(
            networkCheck: {
                throw AppError.message("No internet connection. Please check your network settings.")
            }
        )
        viewModel.userInputText = "paisulparee01@gmail.com"
        viewModel.password = "faisul12345!"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "No internet connection. Please check your network settings.")
        XCTAssertEqual(mock.callCount, 0)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testNilPayloadThrowsDataNotFound() async {
        let mock = MockLoginAPI.mock(
            result: .success(AuthLoginResponse(payload: nil))
        )
        let viewModel = LoginVM()
        viewModel.userInputText = "person@example.com"
        viewModel.password = "password"

        await viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "data not found")
        XCTAssertEqual(mock.callCount, 1)
        XCTAssertFalse(viewModel.isAuthenticated)
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

final class MockRequestBuilderFactory: RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        MockRequestBuilder<T>.self
    }

    func getBuilder<T: Decodable>() -> RequestBuilder<T>.Type {
        MockRequestBuilder<T>.self
    }
}

final class MockRequestBuilder<T>: RequestBuilder<T> {
    override func execute(_ completion: @escaping (_ response: Response<T>?, _ error: Error?) -> Void) {
        if let mock = MockLoginAPI.active {
            mock.record(parameters: parameters)
            let httpResponse = HTTPURLResponse(
                url: URL(string: URLString) ?? APIConstants.baseURL,
                statusCode: 200,
                httpVersion: nil,
                headerFields: headers
            )!

            switch mock.result {
            case let .success(body):
                completion(Response(response: httpResponse, body: body as? T), nil)
            case let .failure(error):
                completion(nil, error)
            }
        } else {
            completion(nil, nil)
        }
    }
}

@MainActor
final class MockLoginAPI {
    static var active: MockLoginAPI?

    let result: Result<Any, Error>
    private(set) var callCount = 0
    private(set) var lastParameters: [String: Any]?

    var email: String? {
        lastParameters?["email"] as? String
    }

    var password: String? {
        lastParameters?["password"] as? String
    }

    init(result: Result<Any, Error>) {
        self.result = result
    }

    @discardableResult
    static func mock(result: Result<Any, Error>) -> MockLoginAPI {
        let instance = MockLoginAPI(result: result)
        active = instance
        return instance
    }

    static func reset() {
        active = nil
    }

    func record(parameters: [String: Any]?) {
        callCount += 1
        lastParameters = parameters
    }
}

private enum TestError: LocalizedError {
    case rejected

    var errorDescription: String? {
        "Credentials were rejected."
    }
}
