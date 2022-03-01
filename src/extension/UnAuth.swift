//
//  UnAuth.swift
//  extension
//
//  Created by Samuel Ivarsson on 2020-01-06.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

import CommonCrypto

extension String {
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

extension RangeReplaceableCollection  {
    /// Returns a new collection containing this collection shuffled
    var shuffled: Self {
        var elements = self
        return elements.shuffleInPlace()
    }
    /// Shuffles this collection in place
    @discardableResult
    mutating func shuffleInPlace() -> Self  {
        indices.forEach {
            let subSequence = self[$0...$0]
            let index = indices.randomElement()!
            replaceSubrange($0...$0, with: self[index...index])
            replaceSubrange(index...index, with: subSequence)
        }
        return self
    }
    func choose(_ n: Int) -> SubSequence { return shuffled.prefix(n) }
}

public class UnAuth {
    
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
    
    private func createRequest(method: String, apiRequest: String) -> URLRequest {
        
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
    
    private func sendRequest(request: URLRequest, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
                
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
    
    private func dsidGen() -> String {
        var dsid = String(Int.random(in: 1...999999)).sha1()
        dsid = String(dsid.suffix(dsid.count-Int.random(in: 1...30)))
        dsid = String(dsid.prefix(8))
        dsid = String(dsid.prefix(4) + dsid.suffix(4).uppercased())
        
        return String(dsid.shuffled())
    }
        
}
