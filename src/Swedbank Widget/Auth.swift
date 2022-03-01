//
//  UnAuth.swift
//  extension
//
//  Created by Samuel Ivarsson on 2020-01-06.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

public class Autho: Auth {
    
    private var _baseUri = "https://auth.api.swedbank.se/TDE_DAP_Portal_REST_WEB/api/"
    private var _apiVersion = "v5"
    private var _appID: String
    private var _userAgent: String
    private var _authorization: String
    private var _profileType: String
    
    init(bankApp: String, debug: Bool = false) {
        self._appID = ""
        self._userAgent = ""
        self._authorization = ""
        self._profileType = ""
        setAppData(appdata: AppData.bankAppId(bankApp: bankApp))
        setAuthorizationKey()
        setBaseUri("https://auth.api.swedbank.se/TDE_DAP_Portal_REST_WEB/api/")
    }
    
    public func setAppData(appdata: [String: String]) {
        if (appdata["appID"] == nil || appdata["useragent"] == nil) {
            print("Not valid app data.")
            exit(3)
        } else {
            guard let appid = appdata["appID"] else {
                print("App ID could not be set")
                exit(4)
            }
            guard let useragent = appdata["useragent"] else {
                print("Useragent could not be set")
                exit(5)
            }
            self._appID = appid
            self._userAgent = useragent
            let profiletype = (useragent.contains("Corporate")) ? "corporateProfiles" : "privateProfile"
            self._profileType = profiletype
        }
    }
        
    public func setAuthorizationKey(key: String = "") {
        self._authorization = (key.count < 1) ? genAuthorizationKey() : key
    }
    
    public func genAuthorizationKey() -> String {
        let string = self._appID + ":" + UUID().uuidString
        let data = string.data(using: String.Encoding.utf8)
        guard let output: String = data?.base64EncodedString() else {
            print("Error for some reason while generating auth key")
            exit(6)
        }
        return output
    }
    
    public func getRequest(apiRequest: String, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        let request = createRequest(method: "get", apiRequest: apiRequest)
        sendRequest(request: request, completion: completion)
    }
    
    public func createRequest(method: String, apiRequest: String, headers: [String: String] = [:], data: Data = Data()) -> URLRequest {
        
        let dsid = dsidGen()
        let dsidString = "dsid=\(dsid)"
        
        let url = URL(string: self._baseUri + self._apiVersion + "/" + apiRequest + "?" + dsidString)
        guard let requestUrl = url else {
            print("Error for some reason while setting requestUrl in createRequest")
            exit(7)
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.uppercased()
        
        request.setValue(self._authorization, forHTTPHeaderField: "Authorization")
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("sv-se", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")
        request.setValue("keep-alive", forHTTPHeaderField: "Proxy-Connection")
        request.setValue(self._userAgent, forHTTPHeaderField: "User-Agent")
        
        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            HTTPCookiePropertyKey.domain: ".api.swedbank.se",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: "dsid",
            HTTPCookiePropertyKey.value: dsid
        ]
        
        if let cookie = HTTPCookie(properties: cookieProps) {
            HTTPCookieStorage.shared.setCookie(cookie)
        }
        
        return request
    }
    
    func sendRequest(request: URLRequest, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
                
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                completion(nil, nil)
                return
            }
            
            // Read HTTP Response Status code
            guard let response = response as? HTTPURLResponse else {
                completion(nil, nil)
                return
            }
            print("Response HTTP Status code: \(response.statusCode)")
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(json, response)
                } catch {
                    let addvalue = error.localizedDescription
                    let newResponse = createHTTPURLResponse(response: response,
                                                            addValue: addvalue,
                                                            toKey: "MYERROR")
                    completion(nil, newResponse)
                }
            } else {
                let addvalue = "Couldn't extract data from URLSession"
                let newResponse = createHTTPURLResponse(response: response,
                                                        addValue: addvalue,
                                                        toKey: "MYDATAERROR")
                completion(nil, newResponse)
            }
            
        }.resume()
    }
    
    public func setBaseUri(_ baseUri: String) {
        self._baseUri = baseUri
    }
    
    func dsidGen() -> String {
        var dsid = String(Int.random(in: 1...999999)).sha1()
        dsid = String(dsid.suffix(dsid.count-Int.random(in: 1...30)))
        dsid = String(dsid.prefix(8))
        dsid = String(dsid.prefix(4) + dsid.suffix(4).uppercased())
        
        return String(dsid.shuffled())
    }
    
    func initAuth(completion: @escaping ([String : Any]?, HTTPURLResponse?) -> Void) {
        print("This function is not implemented in this class.")
        return
    }
    
    func verify(completion: @escaping ([String : Any]?, HTTPURLResponse?) -> Void) {
        print("This function is not implemented in this class.")
        return
    }
    
    func terminate(completion: @escaping ([String : Any]?, HTTPURLResponse?) -> Void) {
        print("This function is not implemented in this class.")
        return
    }
    
    func postRequest(apiRequest: String, body: [String : Any], completion: @escaping ([String : Any]?, HTTPURLResponse?) -> Void) {
        print("This function is not implemented in this class.")
        return
    }
    
    func putRequest(apiRequest: String, completion: @escaping ([String : Any]?, HTTPURLResponse?) -> Void) {
        print("This function is not implemented in this class.")
        return
    }
    
    func getProfileType() -> String {
        print("This function is not implemented in this class.")
        return ""
    }
        
}
