//
//  Main.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2020-01-06.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

public func createHTTPURLResponse(response: HTTPURLResponse, addValue: String, toKey: String) -> HTTPURLResponse {
    guard var headerFields = response.allHeaderFields as? [String: String] else {
        print("Couldn't unwrap headerfields in createHTTPURLResponse")
        exit(7)
    }
    headerFields[toKey] = addValue

    guard let url = response.url else {
        print("Couldn't unwrap url in createHTTPURLResponse")
        exit(8)
    }
    
    let newResponse = HTTPURLResponse(url: url, statusCode: response.statusCode, httpVersion: "HTTP/1.1", headerFields: headerFields)
    
    guard let newResponseUW = newResponse else {
        print("Couldn't unwrap new response in createHTTPURLResponse")
        exit(9)
    }
    
    return newResponseUW
}

public var wasLaunchedByURL: Bool = false

public class Main {
    
    private var auth: MobileBankID
    
    init(bankApp: String, username: String) {
        self.auth = MobileBankID(bankApp: bankApp, username: username)
    }

    public func initAuth(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self.auth.initAuth(completion: completion)
    }
    
    public func verify(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self.auth.verify(completion: completion)
    }
    
    public func terminate(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self.auth.terminate(completion: completion)
    }
    
    public func getAccounts(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        let bankConn = Requests(auth: self.auth)
        
        bankConn.profileList { dictionary, response in
            guard let response = response else {
                completion(nil, nil)
                return
            }
            
            let responseCode = response.statusCode
            if (responseCode < 200 || responseCode >= 300) {
                let addvalue = "Couldn't change profile with POST request"
                let newResponse = createHTTPURLResponse(response: response,
                                                        addValue: addvalue,
                                                        toKey: "MYERROR")
                completion(nil, newResponse)
                return
            }
            
            if let dictionary = dictionary {
                
                guard let hasSwedbankProfile = dictionary["hasSwedbankProfile"] else {
                    let addvalue = "Unknown error with the profile page. (1)"
                    let newResponse = createHTTPURLResponse(response: response,
                                                            addValue: addvalue,
                                                            toKey: "MYERROR")
                    completion(nil, newResponse)
                    return
                }
                
                guard let hasSavingbankProfile = dictionary["hasSavingbankProfile"] else {
                    let addvalue = "Unknown error with the profile page. (2)"
                    let newResponse = createHTTPURLResponse(response: response,
                                                            addValue: addvalue,
                                                            toKey: "MYERROR")
                    completion(nil, newResponse)
                    return
                }
                
                guard let banks = dictionary["banks"] as? [[String: Any]] else {
                    let addvalue = "Couldn't extract banks from HTTP response"
                    let newResponse = createHTTPURLResponse(response: response,
                                                            addValue: addvalue,
                                                            toKey: "MYERROR")
                    completion(nil, newResponse)
                    return
                }
                
                guard banks[0]["bankId"] != nil else {
                    if (hasSwedbankProfile as? Int == 0 && hasSavingbankProfile as? Int == 1) {
                        let addvalue = "The user is not a customer in Swedbank. Please choose one of the Sparbanken's bank types (sparbanken, sparbanken_foretag eller sparbanken_ung)"
                        let newResponse = createHTTPURLResponse(response: response,
                                                                addValue: addvalue,
                                                                toKey: "MYERROR")
                        completion(nil, newResponse)
                        return
                    } else if (hasSwedbankProfile as? Int == 1 && hasSavingbankProfile as? Int == 0) {
                        let addvalue = "The user is not a customer in Sparbanken. Please choose one of the Swedbank's bank types (swedbank, swedbank_foretag eller swedbank_ung)"
                        let newResponse = createHTTPURLResponse(response: response,
                                                                addValue: addvalue,
                                                                toKey: "MYERROR")
                        completion(nil, newResponse)
                        return
                    } else {
                        let addvalue = "The profile do not contain any bank accounts."
                        let newResponse = createHTTPURLResponse(response: response,
                                                                addValue: addvalue,
                                                                toKey: "MYERROR")
                        completion(nil, newResponse)
                        return
                    }
                }
                
                if let profile = banks[0][self.auth.getProfileType()] as? [String: Any] {
                    if let id = profile["id"] as? String {
                        self.auth.postRequest(apiRequest: "profile/"+id, body: [:]) { dictionary2, response2 in
                            guard let response2 = response2 else {
                                completion(nil, nil)
                                return
                            }
                            
                            let responseCode2 = response2.statusCode
                            if (responseCode2 < 200 || responseCode2 >= 300) {
                                let addvalue = "Couldn't change profile with POST request"
                                let newResponse2 = createHTTPURLResponse(response: response2,
                                                                        addValue: addvalue,
                                                                        toKey: "MYERROR")
                                completion(nil, newResponse2)
                                return
                            }

                            bankConn.quickBalanceAccounts(completion: completion)
                        }
                    } else {
                        let addvalue = "Couldn't extract id from profile"
                        let newResponse = createHTTPURLResponse(response: response,
                                                                addValue: addvalue,
                                                                toKey: "MYERROR")
                        completion(nil, newResponse)
                    }
                } else {
                    let addvalue = "Profile Type couldn't be fetched"
                    let newResponse = createHTTPURLResponse(response: response,
                                                            addValue: addvalue,
                                                            toKey: "MYERROR")
                    completion(nil, newResponse)
                }
            }
        }
    }
    
    public func quickBalanceSubscription(quickbalanceSubscriptionID: String, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        let bankConn = Requests(auth: self.auth)
        bankConn.quickBalanceSubscription(quickbalanceSubscriptionID: quickbalanceSubscriptionID, completion: completion)
    }

}
