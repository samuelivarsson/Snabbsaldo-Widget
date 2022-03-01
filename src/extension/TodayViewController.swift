//
//  TodayViewController.swift
//  extension
//
//  Created by Samuel Ivarsson on 2019-12-31.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
            
    private let userDefaultsGroup: UserDefaults? = UserDefaults.init(suiteName: "group.com.samuelivarsson.Swedbank-Widget")
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var diffLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var refreshView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        self.diffLabel.text = ""
        self.label2.text = ""
        self.refreshView.isHidden = true
        self.getBalance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.balanceLabel.text = "Disponibelt belopp"
        self.diffLabel.text = ""
        self.label2.text = ""
        self.refreshView.isHidden = true
        self.getBalance()
    }
    
    private func getBalance() {
        var boolean: Bool = true
        var bankAPP: String = ""
        var subID: String = ""
        
        if let bankApp = self.userDefaultsGroup?.value(forKey: "BANKAPP") as? String {
            if bankApp.count < 8 {
                self.diffLabel.text = "Du har inte ställt in en giltig bank"
                boolean = false
            } else {
                bankAPP = bankApp
            }
        } else {
            self.diffLabel.text = "Du har inte ställt in din bank"
            boolean = false
        }
        
        if let subscriptionId = self.userDefaultsGroup?.value(forKey: "SUBID") as? String {
            if subscriptionId.count < 10 {
                if self.diffLabel.text != "" {
                    self.diffLabel.text = self.diffLabel.text! + " och din premunerationskod är för kort!"
                } else {
                    self.diffLabel.text = "Din premunerationskod är för kort!"
                }
                boolean = false
            } else {
                subID = subscriptionId
            }
        } else {
            if self.diffLabel.text != "" {
                self.diffLabel.text = self.diffLabel.text! + " och premunerationskod!"
            } else {
                self.diffLabel.text = "Du har inte ställt in din premunerationskod!"
            }
            boolean = false
        }
        
        let userDefaults = UserDefaults.standard
        var difference = 0.0
        
        if let lasteDate = userDefaults.object(forKey: "lastDate") as? Date {
            difference = lasteDate.distance(to: Date())
            boolean = !difference.isLess(than: 10)
        } else {
            boolean = true
        }
        
        if (boolean) {
            self.label.text = "Saldo laddas..."
            let main = Main(bankApp: bankAPP, subscriptionId: subID)
            
            if subID == "ExampleXX2GCi3333YpupYBDZX75sOme8Ht9dtuFAKE=" {
                self.label.text = "2103,69" + " " + "SEK"
                self.label.sizeToFit()
                self.label2.text = ""
                self.refreshView.isHidden = true
                userDefaults.set(Date(), forKey: "lastDate")
                return
            }
            
            main.requestBalance(completion: { dictionary, response in
                
                DispatchQueue.main.async {
                    let (responseOK, response) = self.responseCheck(errorString: "quickbalance",
                                                                    responseString: "Couldn't request quickbalance",
                                                                    response: response, dictionary: dictionary)
                    if (!responseOK) {
                        return
                    }
                    
                    if let dictionary = dictionary {
                        let detail = ResponseStruct(dictionary: dictionary)
                        self.label.text = detail.balance + " " + detail.currency
                        self.label.sizeToFit()
                        self.refreshView.isHidden = true
                        if (detail.numberOfReminders > 0) {
                            let end = (detail.numberOfReminders == 1) ? " påminnelse" : " påminnelser"
                            self.label2.text = String(detail.numberOfReminders) + end
                        }
                    } else {
                        self.showError(string: "Unknown error occured (55)", response: response)
                    }
                }
            })
            
            userDefaults.set(Date(), forKey: "lastDate")
            
        } else {
            let waitTime: Int = 10 - Int(difference)
            if self.label.text?.contains("HTTP") ?? false {
                self.label.text = "Saldo laddas..."
            }
            let sekunder = waitTime == 1 ? "sekund" : "sekunder"
            self.label2.text = "Det har inte gått 10 sekunder sedan du uppdatera senast.\nVänta i \(waitTime) "
                                + sekunder + ". " + "Försök sedan igen"
            self.refreshView.isHidden = false
        }
    }

    struct ResponseStruct: Codable {
        let balance: String
        let balanceWithoutDecimals: String
        let currency: String
        let remindersExists: Bool
        let numberOfReminders: Int
        let balanceForCustomer: Bool
        let expirationDate: String
        
        init(dictionary: [String: Any]) {
            self.balance = dictionary["balance"] as? String ?? ""
            self.balanceWithoutDecimals = dictionary["balanceWithoutDecimals"] as? String ?? ""
            self.currency = dictionary["currency"] as? String ?? ""
            self.remindersExists = dictionary["remindersExists"] as? Bool ?? false
            self.numberOfReminders = dictionary["numberOfReminders"] as? Int ?? 0
            self.balanceForCustomer = dictionary["balanceForCustomer"] as? Bool ?? false
            self.expirationDate = dictionary["expirationDate"] as? String ?? ""
        }
    }
    
    private func responseCheck(errorString: String, responseString: String,
                               response: HTTPURLResponse?, dictionary: [String: Any]?) -> (Bool, HTTPURLResponse) {
        
        guard let response = response else {
            DispatchQueue.main.async {
                self.showError(string: "Unexpected error while sending " + errorString + " message", response: HTTPURLResponse())
            }
            return (false, HTTPURLResponse())
        }
        
        let responseCode = response.statusCode
        if (responseCode < 200 || responseCode >= 300) {
            if let dictionary = dictionary {
                DispatchQueue.main.async {
                    self.showError(string: responseString, response: response, dictionary: dictionary)
                }
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
        self.balanceLabel.text = ""
        self.label.text = stringTop
        self.label2.text = stringBottom
    }
    
    private func showError(string: String, response: HTTPURLResponse, dictionary: [String: Any] = [:]) {
        
        self.balanceLabel.text = ""
        
        let apiError = self.getApiError(dictionary: dictionary)
        
        if apiError != "" {
            self.label.text = "HTTP Response code: " + String(response.statusCode)
            if apiError.contains("Du har avaktiverat snabbsaldo") {
                self.label2.text = "Du använder en ogiltig prenumerationskod"
            } else {
                self.label2.text = apiError
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
            
            self.label.text = "HTTP Response code: " + String(response.statusCode)
            self.label2.text = errorString
            self.diffLabel.text = errorDataString
        }
    }
        
//    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
//        // Perform any setup necessary in order to update the view.
//
//        // If an error is encountered, use NCUpdateResult.Failed
//        // If there's no update required, use NCUpdateResult.NoData
//        // If there's an update, use NCUpdateResult.NewData
//
//        completionHandler(NCUpdateResult.newData)
//    }
    
}
