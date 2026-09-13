//
//  AsyncAPIWrapper.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import Foundation

class AsyncAPIWrapper {
    static func callAsync<T>(_ method: @escaping (@escaping (T?, Error?) -> Void) -> Void) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            method { response, error in
                guard error == nil else {
                    return continuation.resume(throwing: error!)
                }
                guard let response = response else {
                    return continuation.resume(throwing: URLError(.cannotParseResponse))
                }
                continuation.resume(returning: response)
            }
        }
    }
}
