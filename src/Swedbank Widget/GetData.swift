//
//  Main.swift
//  My-WidgetExtension
//
//  Created by Samuel Ivarsson on 2020-09-20.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

public class GetData {
    
    var info: String = ""
    var belopp: String = ""
    var belopp2: String = ""
    var belopp3: String = ""
    var belopp4: String = ""
    var waitText: String = ""
    var dispBelopp: String = "Disponibelt belopp"
    var expirationMessage: String = ""
    var name2: String = ""
    var name3: String = ""
    var name4: String = ""
    let userDefaultsGroup: UserDefaults? = UserDefaults.init(suiteName: "group.com.samuelivarsson.Swedbank-Widget")
    
    init() {
        self.info = ""
        self.belopp = ""
        self.belopp2 = ""
        self.belopp3 = ""
        self.belopp4 = ""
        self.waitText = ""
        self.dispBelopp = "Disponibelt belopp"
        self.name2 = ""
        self.name3 = ""
        self.name4 = ""
    }
    
    public func getBalance(primary: Bool, completion: @escaping () -> Void) {
        var boolean: Bool = true
        var bankAPP: String = ""
        var subID: String = ""
        var subID3: String = ""
        var subID4: String = ""
        
        if let bankApp = self.userDefaultsGroup?.value(forKey: "BANKAPP") as? String {
            if bankApp.count < 8 {
                self.info = "Du har inte ställt in en giltig bank"
                boolean = false
            } else {
                bankAPP = bankApp
            }
        } else {
            self.info = "Du har inte ställt in din bank"
            boolean = false
        }
        
        if let subscriptionId = self.userDefaultsGroup?.value(forKey: "SUBID") as? String {
            if subscriptionId.count < 10 {
                if self.info != "" {
                    self.info = self.info + " och din premunerationskod är för kort!"
                } else {
                    self.info = "Din premunerationskod är för kort!"
                }
                boolean = false
            } else {
                subID = subscriptionId
            }
        } else {
            if info != "" {
                self.info = self.info + " eller din premunerationskod!"
            } else {
                self.info = "Du har inte ställt in din premunerationskod!"
            }
            boolean = false
        }
        if let subscriptionId2 = self.userDefaultsGroup?.value(forKey: "SUBID2") as? String {
            if subscriptionId2.count < 10 {
                if self.info != "" {
                    self.info = self.info + " och din premunerationskod är för kort!"
                } else {
                    self.info = "Din premunerationskod är för kort!"
                }
                boolean = false
            } else {
                if !primary {subID = subscriptionId2}
            }
        } else {
            if info != "" {
                self.info = self.info + " eller din premunerationskod!"
            } else {
                self.info = "Du har inte ställt in din premunerationskod!"
            }
            boolean = false
        }
        if let subscriptionId3 = self.userDefaultsGroup?.value(forKey: "SUBID3") as? String {
            if subscriptionId3.count < 10 {
                if self.info != "" {
                    self.info = self.info + " och din premunerationskod är för kort!"
                } else {
                    self.info = "Din premunerationskod är för kort!"
                }
                boolean = false
            } else {
                if !primary {subID3 = subscriptionId3}
            }
        } else {
            if info != "" {
                self.info = self.info + " eller din premunerationskod!"
            } else {
                self.info = "Du har inte ställt in din premunerationskod!"
            }
            boolean = false
        }
        if let subscriptionId4 = self.userDefaultsGroup?.value(forKey: "SUBID4") as? String {
            if subscriptionId4.count < 10 {
                if self.info != "" {
                    self.info = self.info + " och din premunerationskod är för kort!"
                } else {
                    self.info = "Din premunerationskod är för kort!"
                }
                boolean = false
            } else {
                if !primary {subID4 = subscriptionId4}
            }
        } else {
            if info != "" {
                self.info = self.info + " eller din premunerationskod!"
            } else {
                self.info = "Du har inte ställt in din premunerationskod!"
            }
            boolean = false
        }
        
        if (boolean) {
            self.belopp = "Saldo laddas..."
            self.waitText = ""
            let main = Main(bankApp: bankAPP, username: "", subscriptionId: subID)
            
            if subID == "ExampleXX2GCi3333YpupYBDZX75sOme8Ht9dtuFAKE=" {
                self.belopp = "2103,69" + " " + "SEK"
                self.waitText = ""
                self.setUserDefaults()
                return
            }
            
            if !primary {
                main.requestBalance (completion: { dictionary, response in
                    let (responseOK, response) = self.responseCheck(errorString: "quickbalance",
                                                                    responseString: "Couldn't request quickbalance",
                                                                    response: response, dictionary: dictionary)
                    if (!responseOK) {
                        completion()
                        self.setUserDefaults2()
                        return
                    }
                    if let dictionary = dictionary {
                        let detail = ResponseStruct(dictionary: dictionary)
                        self.belopp2 = detail.balance + " " + detail.currency
                        self.name2 = detail.name
                    } else {
                        self.showError(string: "Unknown error occured (55)", response: response)
                    }
                    
                    let main3 = Main(bankApp: bankAPP, username: "", subscriptionId: subID3)
                    main3.requestBalance (completion: { dictionary, response in
                        let (responseOK, response) = self.responseCheck(errorString: "quickbalance",
                                                                        responseString: "Couldn't request quickbalance",
                                                                        response: response, dictionary: dictionary)
                        if (!responseOK) {
                            completion()
                            self.setUserDefaults2()
                            return
                        }
                        if let dictionary = dictionary {
                            let detail = ResponseStruct(dictionary: dictionary)
                            self.belopp3 = detail.balance + " " + detail.currency
                        } else {
                            self.showError(string: "Unknown error occured (55)", response: response)
                        }
                        let main4 = Main(bankApp: bankAPP, username: "", subscriptionId: subID4)
                        main4.requestBalance (completion: { dictionary, response in
                            let (responseOK, response) = self.responseCheck(errorString: "quickbalance",
                                                                            responseString: "Couldn't request quickbalance",
                                                                            response: response, dictionary: dictionary)
                            if (!responseOK) {
                                completion()
                                self.setUserDefaults2()
                                return
                            }
                            if let dictionary = dictionary {
                                let detail = ResponseStruct(dictionary: dictionary)
                                self.belopp4 = detail.balance + " " + detail.currency
                            } else {
                                self.showError(string: "Unknown error occured (55)", response: response)
                            }
                            self.setUserDefaults2()
                            completion()
                        })
                    })
                })
                return
            }
            
            main.requestBalance(completion: { dictionary, response in
                let (responseOK, response) = self.responseCheck(errorString: "quickbalance",
                                                                responseString: "Couldn't request quickbalance",
                                                                response: response, dictionary: dictionary)
                if (!responseOK) {
                    completion()
                    self.setUserDefaults()
                    return
                }
                if let dictionary = dictionary {
                    let detail = ResponseStruct(dictionary: dictionary)
                    self.belopp = detail.balance + " " + detail.currency
                    self.waitText = ""
                    self.dispBelopp = "Disponibelt belopp"
                    self.expirationMessage = detail.expirationMessage
                    if (detail.numberOfReminders > 0) {
                        let end = (detail.numberOfReminders == 1) ? " påminnelse" : " påminnelser"
                        self.waitText = String(detail.numberOfReminders) + end
                    }
                } else {
                    self.showError(string: "Unknown error occured (55)", response: response)
                }
                self.setUserDefaults()
                completion()
            })
        } else {
            self.setUserDefaults()
            completion()
        }
    }
    
    func setUserDefaults() {
        userDefaultsGroup!.set(self.belopp, forKey: "GDBelopp")
        userDefaultsGroup!.set(self.waitText, forKey: "GDWaitText")
        userDefaultsGroup!.set(self.dispBelopp, forKey: "GDDispBelopp")
        userDefaultsGroup!.set(self.info, forKey: "GDInfo")
        userDefaultsGroup!.set(self.expirationMessage, forKey: "GDExpMessage")
    }
    
    func setUserDefaults2() {
        userDefaultsGroup!.set(self.belopp2, forKey: "GDBelopp2")
        userDefaultsGroup!.set(self.belopp3, forKey: "GDBelopp3")
        userDefaultsGroup!.set(self.belopp4, forKey: "GDBelopp4")
        userDefaultsGroup!.set(self.name2, forKey: "GDName2")
        userDefaultsGroup!.set(self.name3, forKey: "GDName3")
        userDefaultsGroup!.set(self.name4, forKey: "GDName4")
        userDefaultsGroup!.set(self.waitText, forKey: "GDWaitText")
        userDefaultsGroup!.set(self.info, forKey: "GDInfo")
        userDefaultsGroup!.set(self.expirationMessage, forKey: "GDExpMessage")
    }
    
    struct ResponseStruct: Codable {
        let balance: String
        let balanceWithoutDecimals: String
        let currency: String
        let remindersExists: Bool
        let numberOfReminders: Int
        let balanceForCustomer: Bool
        let expirationDate: String
        let expirationMessage: String
        let name: String
        
        init(dictionary: [String: Any]) {
            self.balance = dictionary["balance"] as? String ?? ""
            self.balanceWithoutDecimals = dictionary["balanceWithoutDecimals"] as? String ?? ""
            self.currency = dictionary["currency"] as? String ?? ""
            self.remindersExists = dictionary["remindersExists"] as? Bool ?? false
            self.numberOfReminders = dictionary["numberOfReminders"] as? Int ?? 0
            self.balanceForCustomer = dictionary["balanceForCustomer"] as? Bool ?? false
            self.expirationDate = dictionary["expirationDate"] as? String ?? ""
            self.expirationMessage = dictionary["expirationMessage"] as? String ?? ""
            self.name = dictionary["name"] as? String ?? ""
        }
    }
    
    private func responseCheck(errorString: String, responseString: String,
                               response: HTTPURLResponse?, dictionary: [String: Any]?) -> (Bool, HTTPURLResponse) {
        
        guard let response = response else {
            self.showError(string: "Unexpected error while sending " + errorString + " message, maybe no internet connection?", response: HTTPURLResponse())
            return (false, HTTPURLResponse())
        }
        
        let responseCode = response.statusCode
        if (responseCode < 200 || responseCode >= 300) {
            if let dictionary = dictionary {
                self.showError(string: responseString, response: response, dictionary: dictionary)
            }
            return (false, response)
        }
        
        return (true, response)
    }
    
    private func getApiError(dictionary: [String: Any]) -> String {
        var result = ""
        if let errorMessages = dictionary["errorMessages"] as? [String: Any] {
            if let fields = errorMessages["fields"] as? [[String: Any]] {
                for field in fields {
                    if let message = field["message"] as? String {
                        if message.count > 0 {
                            result = message
                        }
                    }
                }
            }
            if let generals = errorMessages["general"] as? [[String: Any]] {
                for general in generals {
                    if let message = general["message"] as? String {
                        if message.count > 0 {
                            result = message
                        }
                    }
                }
            }
        }
        return result
    }
    
    private func showUserError(stringTop: String, stringBottom: String) {
        self.dispBelopp = ""
        self.belopp = stringTop
        self.waitText = stringBottom
    }
    
    private func showError(string: String, response: HTTPURLResponse, dictionary: [String: Any] = [:]) {
        
        self.dispBelopp = ""
        
        let apiError = self.getApiError(dictionary: dictionary)
        
        if apiError != "" {
            self.belopp = "HTTP Response code: " + String(response.statusCode)
            if apiError.contains("Du har avaktiverat snabbsaldo") {
                self.waitText = "Du använder en ogiltig prenumerationskod"
            } else {
                self.waitText = apiError
            }
        } else {
            var errorString = string
            var errorDataString = ""
            if let myerror = response.value(forHTTPHeaderField: "MYERROR") {
                errorString = myerror
            }
            if let mydataerror = response.value(forHTTPHeaderField: "MYDATAERROR") {
                errorDataString = mydataerror
            }
            
            self.belopp = "HTTP Response code: " + String(response.statusCode)
            self.waitText = errorString
            self.info = errorDataString
        }
    }
}
