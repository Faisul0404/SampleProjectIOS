//
//  iBSUserDefaults.swift
//  iBaseSwift
//
//  Created by Dushan Saputhanthri on 3/2/20.
//  Copyright © 2020 Elegant Media Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

public struct AppUserDefaults {
    
    public static let shared = UserDefaults.standard
    
    //MARK: Set FCM token
    public static func setFCMToken(token: String) {
        shared.set(token, forKey: "FCM_TOKEN")
        shared.synchronize()
    }
    
    //MARK: Get FCM token
    public static func getFCMToken() -> String {
        if let token = shared.string(forKey: "FCM_TOKEN") {
            return token
        }
        return ""
    }
    
    //MARK: Set access token
    public static func setAccessToken(token: String) {
        shared.set(token, forKey: "ACCESS_TOKEN")
        shared.synchronize()
    }
    
    //MARK: Get access token
    public static func getAccessToken() -> String {
        if let token = shared.string(forKey: "ACCESS_TOKEN") {
            return token
        }
        return ""
    }
    
    //MARK: Remove access token
    public static func removeAccessToken() {
        shared.object(forKey: "ACCESS_TOKEN")
        shared.synchronize()
    }
    
    //MARK: set Is Subscribed
    public static func setIsSubscribed(to value: Bool) {
        shared.set(value, forKey: "SUBSCRIPTION_STATUS")
        shared.synchronize()
    }
    
    //MARK: get Is Subscribed
    public static func getIsSubscribed() -> Bool {
        return shared.bool(forKey: "SUBSCRIPTION_STATUS")
    }
    
    public static func setCurrentPlan(plan: String) {
        shared.set(plan, forKey: "SUBSCRIPTION_PLAN")
        shared.synchronize()
    }
    
    public static func getCurrentPlan() -> String {
        if let plan = shared.string(forKey: "SUBSCRIPTION_PLAN") {
            return plan
        }
        return ""
    }
    
    //MARK: set Is profileComplete
    public static func setIsProfileCompleted(to value: Bool) {
        shared.set(value, forKey: "PROFILE_COMPLETION_STATUS")
        shared.synchronize()
    }
    
    //MARK: get Is profileComplete
    public static func getIsProfileCompleted() -> Bool {
        return shared.bool(forKey: "PROFILE_COMPLETION_STATUS")
    }

    //MARK: Set unread notification count
    public static func setUnreadNotificationCount(count: Int) {
        shared.set(max(0, count), forKey: "UNREAD_NOTIFICATION_COUNT")
        shared.synchronize()
    }

    //MARK: Get unread notification count
    public static func getUnreadNotificationCount() -> Int {
        return max(0, shared.integer(forKey: "UNREAD_NOTIFICATION_COUNT"))
    }

    //MARK: Set last processed push id
    public static func setLastProcessedPushId(_ pushId: String) {
        shared.set(pushId, forKey: "LAST_PROCESSED_PUSH_ID")
        shared.synchronize()
    }

    //MARK: Get last processed push id
    public static func getLastProcessedPushId() -> String {
        return shared.string(forKey: "LAST_PROCESSED_PUSH_ID") ?? ""
    }
}

struct NotificationBadgeManager {

    @MainActor
    static func updateBadge(count: Int) {
        let safeCount = max(0, count)
        UNUserNotificationCenter.current().setBadgeCount(safeCount, withCompletionHandler: nil)
        AppUserDefaults.setUnreadNotificationCount(count: safeCount)
    }

    @MainActor
    private static func enforceBadge(count: Int) {
        let safeCount = max(0, count)
        updateBadge(count: safeCount)

        // APNs badge value can overwrite local state; re-apply shortly after.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            UNUserNotificationCenter.current().setBadgeCount(safeCount, withCompletionHandler: nil)
            AppUserDefaults.setUnreadNotificationCount(count: safeCount)
        }
    }

    @MainActor
    static func setCachedBadge() {
        let count = AppUserDefaults.getUnreadNotificationCount()
        UNUserNotificationCenter.current().setBadgeCount(count, withCompletionHandler: nil)
    }

    static func refreshUnreadCountFromServer(allowDecrease: Bool = true) async {
        guard !AppUserDefaults.getAccessToken().isEmpty else { return }

        do {
            let response = try await AsyncAPIWrapper.callAsync {
                NotificationsAPI.notificationsGetGetNotificationsCount(
                    accept: ASP.shared.accept,
                    completion: $0
                )
            }
            let unreadCount = response.payload?.count ?? 0
            await MainActor.run {
                if !allowDecrease {
                    let cached = AppUserDefaults.getUnreadNotificationCount()
                    guard unreadCount >= cached else { return }
                }
                updateBadge(count: unreadCount)
                
            }
        } catch {
            // Keep the last cached badge count if refresh fails.
        }
    }

    @MainActor
    static func updateBadgeFromPushPayload(_ userInfo: [AnyHashable: Any]) {
        guard let badgeCount = extractBadgeCount(from: userInfo) else { return }
        updateBadge(count: badgeCount)
    }

    private static func extractBadgeCount(from userInfo: [AnyHashable: Any]) -> Int? {
        if let aps = userInfo["aps"] as? [String: Any] {
            if let badge = aps["badge"] as? Int {
                return badge
            }

            if let badgeString = aps["badge"] as? String,
               let badge = Int(badgeString) {
                return badge
            }
        }

        if let badge = userInfo["badge_count"] as? Int {
            return badge
        }

        if let badgeString = userInfo["badge_count"] as? String,
           let badge = Int(badgeString) {
            return badge
        }

        return nil
    }
}
