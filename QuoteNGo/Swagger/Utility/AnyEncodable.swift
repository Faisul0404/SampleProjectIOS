//
//  AnyEncodable.swift
//  QuoteNGo
//

import Foundation

/**
 A clean, lightweight type-erased `Encodable` wrapper.
 */
public struct AnyEncodable: Encodable, Equatable, CustomStringConvertible {
    public let value: Any

    public init(_ value: Any?) {
        self.value = value ?? ()
    }

    public func encode(to encoder: Encoder) throws {
        try AnyCodable(value).encode(to: encoder)
    }

    public static func == (lhs: AnyEncodable, rhs: AnyEncodable) -> Bool {
        AnyCodable(lhs.value) == AnyCodable(rhs.value)
    }

    public var description: String {
        AnyCodable(value).description
    }
}

extension AnyEncodable: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    public init(nilLiteral: ()) {
        self.init(())
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(arrayLiteral elements: Any...) {
        self.init(elements)
    }

    public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
        self.init(Dictionary(elements, uniquingKeysWith: { first, _ in first }))
    }
}

