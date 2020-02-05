//
//  Requests.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2019-12-29.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
//

import Foundation

public class Requests {
    
    private var _auth: UnAuth
    private var _profileID: String
    
    init(auth: UnAuth) {
        self._auth = auth
        self._profileID = ""
    }
    
    public func quickBalance(subscriptionId: String, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self._auth.getRequest(apiRequest: "quickbalance/" + subscriptionId, completion: completion)
    }
}
