import Foundation
import UIKit

struct LoginCredentials: Equatable {
    let email: String?
    let phone: String?
    let password: String
}

struct LoginResponse: Decodable {
    let token: String

    private enum CodingKeys: String, CodingKey {
        case token
        case accessToken = "access_token"
        case payload
    }

    private struct Payload: Decodable {
        let token: String

        private enum CodingKeys: String, CodingKey {
            case token
            case accessToken = "access_token"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            token = try container.decodeIfPresent(String.self, forKey: .token)
                ?? container.decode(String.self, forKey: .accessToken)
        }
    }

    init(token: String) {
        self.token = token
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let token = try container.decodeIfPresent(String.self, forKey: .token)
            ?? container.decodeIfPresent(String.self, forKey: .accessToken) {
            self.token = token
        } else {
            token = try container.decode(Payload.self, forKey: .payload).token
        }
    }
}

@MainActor
protocol AuthServicing {
    func login(credentials: LoginCredentials) async throws -> LoginResponse
}

enum AuthServiceError: LocalizedError {
    case invalidResponse
    case server(statusCode: Int, message: String)

    var statusCode: Int? {
        guard case let .server(statusCode, _) = self else { return nil }
        return statusCode
    }

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .server(_, message):
            return message
        }
    }
}

struct AuthService: AuthServicing {
    private let session: URLSession
    private let deviceID: String
    private let devicePushToken: String?

    init(
        session: URLSession = .shared,
        deviceID: String = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
        devicePushToken: String? = nil
    ) {
        self.session = session
        self.deviceID = deviceID
        self.devicePushToken = devicePushToken
    }

    func login(credentials: LoginCredentials) async throws -> LoginResponse {
        let request = makeLoginRequest(credentials: credentials)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthServiceError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw AuthServiceError.server(
                statusCode: httpResponse.statusCode,
                message: errorResponse?.message ?? "Sign in failed (HTTP \(httpResponse.statusCode))."
            )
        }

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func makeLoginRequest(credentials: LoginCredentials) -> URLRequest {
        let url = APIConstants.baseURL.appendingPathComponent(APIConstants.loginPath)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(APIConstants.apiKey, forHTTPHeaderField: "apiKey")

        var formFields = [
            URLQueryItem(name: "device_id", value: deviceID),
            URLQueryItem(name: "device_type", value: "APPLE"),
            URLQueryItem(name: "password", value: credentials.password)
        ]
        if let email = credentials.email {
            formFields.append(URLQueryItem(name: "email", value: email))
        }
        if let phone = credentials.phone {
            formFields.append(URLQueryItem(name: "phone", value: phone))
        }
        if let devicePushToken {
            formFields.append(URLQueryItem(name: "device_push_token", value: devicePushToken))
        }
        var components = URLComponents()
        components.queryItems = formFields
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        return request
    }
}

private struct APIErrorResponse: Decodable {
    let message: String
}