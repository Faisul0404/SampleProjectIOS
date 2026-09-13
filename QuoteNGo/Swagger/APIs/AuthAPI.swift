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
    
    
}
