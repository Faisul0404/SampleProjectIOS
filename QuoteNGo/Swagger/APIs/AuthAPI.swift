//
//  AuthAPI.swift
//  QuoteNGo
//
//  Created by Developer on 2026-09-13.
//

import Foundation

open class AuthAPI {
    
    /**
     Logout

     - parameter accept: (header) Set to &#x60;application/json&#x60;
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authGetLogout(accept: String, completion: @escaping ((_ data: SuccessResponse?,_ error: Error?) -> Void)) {
        authGetLogoutWithRequestBuilder(accept: accept).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Logout
     - GET /logout

     - API Key:
       - type: apiKey x-access-token
       - name: accessToken
     - API Key:
       - type: apiKey x-api-key
       - name: apiKey
     - examples: [{contentType=application/json, example={
  "result" : true,
  "payload" : { },
  "message" : "message"
}}]
     - parameter accept: (header) Set to &#x60;application/json&#x60;

     - returns: RequestBuilder<SuccessResponse>
     */
    open class func authGetLogoutWithRequestBuilder(accept: String) -> RequestBuilder<SuccessResponse> {
        let path = "/logout"
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        let url = URLComponents(string: URLString)
        let nillableHeaders: [String: Any?] = [
                        "Accept": accept
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<SuccessResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    
    
    /**
     Login

     - parameter deviceId: (form)
     - parameter deviceType: (form)
     - parameter devicePushToken: (form)
     - parameter email: (form)
     - parameter password: (form)
     - parameter accept: (header) &#x60;application/json&#x60;
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func authPostLogin(deviceId: String, deviceType: String, devicePushToken: String, email: String, password: String, accept: String, completion: @escaping ((_ data: AuthLoginResponse?,_ error: Error?) -> Void)) {
        authPostLoginWithRequestBuilder(deviceId: deviceId, deviceType: deviceType, devicePushToken: devicePushToken, email: email, password: password, accept: accept).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Login
     - POST /login
     -

     - API Key:
       - type: apiKey x-api-key
       - name: apiKey
     - examples: [{contentType=application/json, example={
  "result" : true,
  "payload" : {
    "access_token" : "access_token",
    "full_name" : "full_name",
    "avatar_url" : "avatar_url",
    "profile_complete_step" : "profile_complete_step",
    "timezone" : "timezone",
    "last_name" : "last_name",
    "is_subscribed" : "is_subscribed",
    "email_verified_at" : "email_verified_at",
    "uuid" : "uuid",
    "first_name" : "first_name",
    "email" : "email"
  },
  "message" : "message"
}}]
     - parameter deviceId: (form)
     - parameter deviceType: (form)
     - parameter devicePushToken: (form)
     - parameter email: (form)
     - parameter password: (form)
     - parameter accept: (header) &#x60;application/json&#x60;

     - returns: RequestBuilder<AuthLoginResponse>
     */
    open class func authPostLoginWithRequestBuilder(deviceId: String, deviceType: String, devicePushToken: String, email: String, password: String, accept: String) -> RequestBuilder<AuthLoginResponse> {
        let path = "/login"
        let URLString = SwaggerClientAPI.basePath + path
        let formParams: [String:Any?] = [
            "device_id": deviceId,
            "device_type": deviceType,
            "device_push_token": devicePushToken,
            "email": email,
            "password": password
        ]
        let nonNullParameters = APIHelper.rejectNil(formParams)
        let parameters = APIHelper.convertBoolToString(nonNullParameters)
        
        let url = URLComponents(string: URLString)
        let nillableHeaders: [String: Any?] = [
            "Accept": accept
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<AuthLoginResponse>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "POST", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
}
