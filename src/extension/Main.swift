//
//  Main.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2019-12-30.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
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

public class Main {
    
    private let bankApp: String
    private let subscriptionId: String
    
    init(bankApp: String, subscriptionId: String) {
        self.bankApp = bankApp
        self.subscriptionId = subscriptionId
    }

    public func requestBalance(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {

        let auth     = UnAuth(bankApp: self.bankApp)
        let bankConn = Requests(auth: auth)

        bankConn.quickBalance(subscriptionId: self.subscriptionId, completion: completion)

    }
}
