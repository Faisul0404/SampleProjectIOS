//
//  AnyDecodable.swift
//  QuoteNGo
//

import Foundation

/**
 A clean, lightweight type-erased `Decodable` wrapper.
 */
public struct AnyDecodable: Decodable, Equatable, CustomStringConvertible {
    public let value: Any

    public init(_ value: Any?) {
        self.value = value ?? ()
    }

    public init(from decoder: Decoder) throws {
        let codable = try AnyCodable(from: decoder)
        self.value = codable.value
    }

    public static func == (lhs: AnyDecodable, rhs: AnyDecodable) -> Bool {
        AnyCodable(lhs.value) == AnyCodable(rhs.value)
    }

    public var description: String {
        AnyCodable(value).description
    }
}

