//
//  Requests.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2020-01-06.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

public class Requests {

    private var _auth: MobileBankID
    private var _profileID: String
    
    init(auth: MobileBankID) {
        self._auth = auth
        self._profileID = ""
    }
    
    public func profileList(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self._auth.getRequest(apiRequest: "profile/", completion: completion)
    }

    public func quickBalanceAccounts(completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self._auth.getRequest(apiRequest: "quickbalance/accounts", completion: completion)
    }

    public func quickBalanceSubscription(quickbalanceSubscriptionID: String, completion: @escaping ([String: Any]?, HTTPURLResponse?) -> Void) {
        self._auth.postRequest(apiRequest: "quickbalance/subscription/"+quickbalanceSubscriptionID, body: [:], completion: completion)
    }
    
    public func setProfileID(profileID: String) {
        self._profileID = profileID
    }
}
