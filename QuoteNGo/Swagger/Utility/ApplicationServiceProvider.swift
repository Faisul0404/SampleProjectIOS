//
//  ApplicationService.swift
//  Copyright © 2019 ElegantMedia. All rights reserved.
//

import Foundation
import UIKit

let ASP = ApplicationServiceProvider.self

enum Storyboard: String {
    case Auth
    case Main
    case SideMenu
    case TabBar
    case Settings
}

class ApplicationServiceProvider {
    
    static let shared = ApplicationServiceProvider()
    
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    let deviceType = "APPLE"
    let accept = "application/json"
    
    // MARK: Update this if any Realm property changed happened
    let realmSchemaVersion: UInt64 = 0
    
    // Initial parameters for authenication services (Login / Register)
    var initialAuthParameters: [String: Any] = [:]
    
    public init() {}
    
    // Configure Application
    func configure() {
        
        self.setInitialAuthParameters()
        
        //MARK: App logger
        self.configureLogger()
        
        //MARK: Manage app UI
        self.manageUIAppearance()
    }
    
    //MARK: Setup initial auth parameters
    private func setInitialAuthParameters() {
        let dict = [
            "device_id": ASP.shared.deviceId,
            "device_type": ASP.shared.deviceType,
            "device_push_token": AppUserDefaults.getFCMToken()
        ]
        
        initialAuthParameters.updateDictionary(otherValues: dict)
    }
    
    
    //MARK: Setup application appearance
    private func manageUIAppearance(hasCustomBackButton: Bool = false, hideNavBarShadow: Bool = false, hideTabBarShadow: Bool = false) {
        // Set navigation bar tint / background color
        UINavigationBar.appearance().isTranslucent = false
        
        // Set navigation bar item tint color
        UIBarButtonItem.appearance().tintColor = .darkGray
        
        // Set navigation bar back button tint color
        UINavigationBar.appearance().tintColor = .darkGray
        
        // Set cutom back image if needed
        if hasCustomBackButton == true {
            // Set back button image
            let backImage = #imageLiteral(resourceName: "ic_back")
            UINavigationBar.appearance().backIndicatorImage = backImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        }
        
        // Hide navigation bar shadow if needed
        if hideNavBarShadow == true {
            // To remove the 1px seperator at the bottom of navigation bar
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
        }
        
        // Hide tab bar shadow if needed
        if hideTabBarShadow == true {
            // To remove the 1px seperator at the bottom of tab bar
            UITabBar.appearance().backgroundImage = UIImage()
            UITabBar.appearance().shadowImage = UIImage()
        }
    }
    
    
    //MARK: Logger
    private func configureLogger() {
//        let console = ConsoleDestination() // log to Xcode Console
       
    }
    
    //MARK: Setup access token
    func setupAccessToken() {
        guard PersistenceController.shared.accessToken != nil else {
            return
        }
        
        SwaggerClientAPI.customHeaders.updateValue(AppUserDefaults.getAccessToken(), forKey: "x-access-token")
    }
    
}

