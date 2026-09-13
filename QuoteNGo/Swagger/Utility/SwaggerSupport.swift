import Foundation
import Alamofire

public struct Response<T> {
    public let response: HTTPURLResponse
    public let body: T?

    public init(response: HTTPURLResponse, body: T?) {
        self.response = response
        self.body = body
    }
}

public enum ErrorResponse: LocalizedError {
    case error(Int, Data?, Error)

    public var errorDescription: String? {
        guard case let .error(_, _, error) = self else { return nil }
        return (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }
}

public enum APIHelper {
    public static func rejectNil(_ source: [String: Any?]) -> [String: Any] {
        source.compactMapValues { $0 }
    }

    public static func rejectNilHeaders(_ source: [String: Any?]) -> [String: String] {
        source.compactMapValues { value in
            guard let value else { return nil }
            return String(describing: value)
        }
    }

    public static func convertBoolToString(_ source: [String: Any]) -> [String: Any] {
        source.mapValues { value in
            guard let boolValue = value as? Bool else { return value }
            return boolValue ? "true" : "false"
        }
    }
}

public enum CodableHelper {
    public static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> (decodableObj: T?, error: Error?) {
        do {
            return (try JSONDecoder().decode(type, from: data), nil)
        } catch {
            return (nil, error)
        }
    }
}

public struct JSONDataEncoding: ParameterEncoding {
    public init() {}

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        guard let parameters else { return request }
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}