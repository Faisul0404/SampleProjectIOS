//
//  AppError.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-13.
//

import Foundation

public enum AppError: LocalizedError {
    case message(String)

    public var errorDescription: String? {
        switch self {
        case let .message(text):
            return text
        }
    }
}
