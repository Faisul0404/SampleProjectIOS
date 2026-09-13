//
//  LoginVM.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-12.
//

import Foundation
import Combine

class LoginVM: ObservableObject {
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
}

