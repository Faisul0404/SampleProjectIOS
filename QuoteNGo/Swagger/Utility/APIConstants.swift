import Foundation

public class APIConstants {
    //MARK: Base URL
    public static var baseURL = URL(string: "https://quotengo.sandbox29.preview.cx/api/v1")!
    
    //MARK: RESTful API key
    public static var apiKey = "6a9a92ef1d669fd66859f1f3a8faad1f"

    //MARK: Auth endpoints
    public static var loginPath = "login"

    //MARK: Custom headers
    public static var customHeaders: [String: String] = [:]
    
    //MARK: Get Updated Custom headers
    public static func getCustomHeaders() -> [String: String] {
        
        customHeaders = ["x-api-key": apiKey, "Accept" : "application/json"]
        
        // Check access token exits
        if let accessToken = PersistenceController.shared.accessToken {
            // Add access token to current custom headers
            customHeaders.updateValue(accessToken, forKey: "x-access-token")
        }
        
        return customHeaders
    }
    
    
}
