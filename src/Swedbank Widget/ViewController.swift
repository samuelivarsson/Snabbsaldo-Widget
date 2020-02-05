//
//  ViewController.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2019-12-28.
//  Copyright © 2019 Samuel Ivarsson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private var main: Main = Main(bankApp: "sparbanken", username: "0000000000")
    private var accounts: [[String: Any]] = [[:]]
    private var quickbalanceSubscriptionID: String = ""
    private let userDefaultsGroup: UserDefaults? = UserDefaults.init(suiteName: "group.com.samuelivarsson.Swedbank-Widget")
    private var _subID: String = ""
    private var bankapp: String = ""
    private var bankappSetFromView1: Bool = false
    private var bankappSetFromSetView: Bool = false
    private var username: String = ""
    private var bankappString: String = ""
    private var myTimer: Timer?
    private var timerSeconds: Int = 0
    private var didOpenBankID: Bool = false
    
    private let testAccounts: [[String: Any]] = [
                                                ["name": "Sparkonto", "quickbalanceSubscription": ["id": "ExampleAccountID"]],
                                                ["name": "Privatkonto", "quickbalanceSubscription": ["id": "ExampleAccountID"]],
                                                ["name": "Nöjen", "quickbalanceSubscription": ["id": "ExampleAccountID"]],
                                                ["name": "e-Sparkonto", "quickbalanceSubscription": ["id": "ExampleAccountID"]],
                                                ]
    
    @IBOutlet weak var startupView: UIView!
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var setView: UIView!
    
    @IBOutlet weak var errorLabelView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorTopLabel: UILabel!
    
    @IBOutlet weak var startUpBankLabel: UILabel!
    @IBOutlet weak var startUpIDLabel: UILabel!
    @IBOutlet weak var view1TextField: UITextField!
    @IBOutlet weak var view2Label: UILabel!
    @IBOutlet weak var view3Label: UILabel!
    @IBOutlet weak var view3PickerView: UIPickerView!
    @IBOutlet weak var view4SubLabel: UILabel!
    @IBOutlet weak var view4CopyLabel: UILabel!
    
    @IBOutlet weak var bankButton: UIButton!
    @IBOutlet var bankButtons: [UIButton]!
    @IBOutlet weak var bankStackView: UIStackView!
    @IBOutlet weak var bankButton2: UIButton!
    @IBOutlet weak var bankStackView2: UIStackView!
    @IBOutlet var bankButtons2: [UIButton]!
    
    @IBOutlet weak var setViewTextView: UITextView!
    @IBOutlet weak var setViewTextField: UITextField!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let name = accounts[row]["name"] as? String else {
            return "Error"
        }
        return name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let dict = accounts[row]["quickbalanceSubscription"] as? [String: Any] {
            if let id = dict["id"] as? String {
                if let name = accounts[row]["name"] as? String {
                    view3Label.text = "Valt konto: " + name
                    self.quickbalanceSubscriptionID = id
                }
            } else {
                view3Label.text = "Error, something went wrong (1)"
            }
        } else {
            view3Label.text = "Error, something went wrong (2)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupTextViews()
        self.setupTextFields()
        self.errorLabelView.isHidden = true
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appDidBecomeForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.showStartupScreen()
        self.view1.bringSubviewToFront(bankStackView)
    }
    
    @objc func appDidBecomeForeground() {
        if wasLaunchedByURL && self.didOpenBankID {
            wasLaunchedByURL = false
            self.didOpenBankID = false
            self.verifyBankID()
        }
    }
    
    @IBAction func beginButtonTapped(_ sender: Any) {
        self.showFirstScreen()
    }
    
    @IBAction func viewOneBackButton(_ sender: Any) {
        self.showStartupScreen()
    }
    
    @IBAction func viewTwoCancelButton(_ sender: Any) {
        main.terminate { dictionary, response in
            let (responseOK, _) = self.responseCheck(errorString: "logout",
                                                            responseString: "Couldn't logout",
                                                            response: response, dictionary: dictionary)
            if (!responseOK) {
                return
            }
            
            DispatchQueue.main.async {
                self.showUserError(stringTop: "Begäran lyckades", stringBottom: "Du loggades ut")
            }
        }
        self.showFirstScreen()
    }
    
    @IBAction func viewThreeCancelButton(_ sender: Any) {
        main.terminate { dictionary, response in
            let (responseOK, _) = self.responseCheck(errorString: "logout",
                                                            responseString: "Couldn't logout",
                                                            response: response, dictionary: dictionary)
            if (!responseOK) {
                return
            }
            
            DispatchQueue.main.async {
                self.showUserError(stringTop: "Begäran lyckades", stringBottom: "Du loggades ut")
            }
        }
        self.showFirstScreen()
    }
    
    @IBAction func setCodeButtonTapped(_ sender: Any) {
        self.showSetScreen()
    }
    
    @IBAction func setViewBackButtonTapped(_ sender: Any) {
        self.showStartupScreen()
    }
    
    @IBAction func setViewSetButtonTapped(_ sender: Any) {
        if self.setViewTextField.text!.count < 10 {
            self.showUserError(stringTop: "Felaktig parameter", stringBottom: "Koden är för kort...")
            return
        }
        if !bankappSetFromSetView {
            self.showUserError(stringTop: "Felaktig parameter", stringBottom: "Ingen bank vald")
            return
        }
        
        self.userDefaultsGroup?.setValue(self.setViewTextField.text!, forKey: "SUBID")
        self.userDefaultsGroup?.setValue(self.bankapp, forKey: "BANKAPP")
        self.userDefaultsGroup?.setValue(self.bankappString, forKey: "BANKAPPSTRING")
        self.showStartupScreen()
    }
    
    func setupTextViews() {
        self.setViewTextView.centerVertically()
    }
    
    func setupTextFields() {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        self.view1TextField.inputAccessoryView = toolbar
        self.setViewTextField.inputAccessoryView = toolbar

        self.view1TextField.attributedPlaceholder = NSAttributedString(string: "Personnummer",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.setViewTextField.attributedPlaceholder = NSAttributedString(string: "Klistra in prenumerationskoden här...",
                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    enum Banks: String {
        case swedbank = "Swedbank"
        case sparbanken = "Sparbanken"
        case swedbank_foretag = "Swedbank Företag"
        case sparbanken_foretag = "Sparbanken Företag"
    }
    
    @IBAction func bankButtonTapped(_ sender: Any) {
        self.bankButtons.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
        
        self.setupTextViews()
    }
    
    @IBAction func bankTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let bank = Banks(rawValue: title) else {
            return
        }
        
        switch bank {
        case .sparbanken:
            self.bankapp = "sparbanken"
        case .sparbanken_foretag:
            self.bankapp = "sparbanken_foretag"
        case .swedbank:
            self.bankapp = "swedbank"
        case .swedbank_foretag:
            self.bankapp = "swedbank_foretag"
        }
        
        self.bankappSetFromView1 = true
        self.bankappString = title
        
        self.bankButton.setTitle(title, for: .normal)
        self.bankButton.setTitleColor(UIColor.black, for: .normal)
        
        self.bankButtons.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
        
        self.setupTextViews()
    }
    
    @IBAction func bankButton2Tapped(_ sender: Any) {
        self.bankButtons2.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
        
        self.setupTextViews()
    }

    @IBAction func bank2Tapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let bank = Banks(rawValue: title) else {
            return
        }
        
        switch bank {
        case .sparbanken:
            self.bankapp = "sparbanken"
        case .sparbanken_foretag:
            self.bankapp = "sparbanken_foretag"
        case .swedbank:
            self.bankapp = "swedbank"
        case .swedbank_foretag:
            self.bankapp = "swedbank_foretag"
        }
        
        self.bankappSetFromSetView = true
        self.bankappString = title
        
        self.bankButton2.setTitle(title, for: .normal)
        self.bankButton2.setTitleColor(UIColor.black, for: .normal)
        
        self.bankButtons2.forEach { button in
            UIView.animate(withDuration: 0.3) {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            }
        }
        
        self.setupTextViews()
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
    
    @IBAction func loginButtonTapped(_ sender: Any) {

        self.username = self.view1TextField.text!
        
        if (self.username.count < 10) {
            self.showUserError(stringTop: "Felaktig parameter", stringBottom: "Personnumret måste vara minst 10 siffror")
            return
        }
        if !bankappSetFromView1 {
            self.showUserError(stringTop: "Felaktig parameter", stringBottom: "Ingen bank vald")
            return
        }
        if self.username == "0000000000" {
            self.accounts = self.testAccounts
            self.view3PickerView.reloadAllComponents()
            self.showThirdScreen()
            return
        }
        
        self.main = Main(bankApp: self.bankapp, username: self.username)
        
        main.initAuth { dictionary, response in
            DispatchQueue.main.async {
                let (responseOK, response) = self.responseCheck(errorString: "authentication",
                                                                responseString: "Couldn't initiate authentication with mobile bankid",
                                                                response: response, dictionary: dictionary)
                if (!responseOK) {
                    return
                }
                
                if let dictionary = dictionary {
                    if let status = dictionary["status"] as? String {
                        if status != "USER_SIGN" {
                            self.showError(string: "Unable to use Mobile BankID. Check if the user have enabled Mobile BankID.", response: response)
                            return
                        } else {
                            print("\nStage 1 complete!\n")
                            self.showSecondScreen()
                            self.openBankID()
                        }
                    } else {
                        self.showError(string: "Couldn't extract status parameter from HTTP response",
                                       response: response, dictionary: dictionary)
                    }
                } else {
                    self.showError(string: "", response: response)
                }
            }
        }
    }
    
    @IBAction func verifyButtonTapped(_ sender: Any) {
        self.verifyBankID()
    }
    
    private func verifyBankID() {
        main.verify { dictionary, response in
            DispatchQueue.main.async {
                let (responseOK, response) = self.responseCheck(errorString: "verification",
                                                                responseString: "Couldn't send verification message",
                                                                response: response, dictionary: dictionary)
                if (!responseOK) {
                    return
                }
                
                if let dictionary = dictionary {
                    if let status = dictionary["status"] as? String {
                        if status == "COMPLETE" {
                            print("\nStage 2 complete!\n")
                            self.getAccounts()
                        } else {
                            self.showError(string: "Login hasn't been verified with your bank-id yet, please try again", response: response)
                        }
                    } else {
                        self.showError(string: "Couldn't extract status parameter from HTTP response",
                                       response: response, dictionary: dictionary)
                    }
                } else {
                    self.showError(string: "", response: response)
                }
            }
        }
    }
    
    private func getAccounts() {
        main.getAccounts { dictionary, response in
            DispatchQueue.main.async {
                let (responseOK, response) = self.responseCheck(errorString: "get-account",
                                                                responseString: "Couldn't fetch accounts",
                                                                response: response, dictionary: dictionary)
                if (!responseOK) {
                    return
                }
                
                if let dictionary = dictionary {
                    if let accounts = dictionary["accounts"] as? [[String: Any]] {
                        self.accounts = accounts
                        self.view3PickerView.reloadAllComponents()
                        print("\nStage 3 complete!\n")
                        self.showThirdScreen()
                    } else {
                        self.showError(string: "Couldn't extract accounts from http response",
                                       response: response, dictionary: dictionary)
                    }
                } else {
                    self.showError(string: "", response: response)
                }
            }
        }
    }
    
    @IBAction func chooseButtonTapped(_ sender: Any) {
        
        if self.quickbalanceSubscriptionID == "ExampleAccountID" {
            self._subID = "ExampleXX2GCi3333YpupYBDZX75sOme8Ht9dtuFAKE="
            self.view4SubLabel.text = "Din prenumerationskod är:\n\n" + self._subID
            self.showFourthScreen()
            return
        }
        
        main.quickBalanceSubscription(quickbalanceSubscriptionID: self.quickbalanceSubscriptionID) { dictionary, response in
            let (responseOK, response) = self.responseCheck(errorString: "choose-account",
                                                            responseString: "Couldn't choose account",
                                                            response: response, dictionary: dictionary)
            if (!responseOK) {
                return
            }
            
            if let dictionary = dictionary {
                if let subid = dictionary["subscriptionId"] as? String {
                    DispatchQueue.main.async {
                        self._subID = subid
                        self.view4SubLabel.text = "Din prenumerationskod är:\n\n" + self._subID
                        print("\nStage 4 complete!\n")
                        self.showFourthScreen()
                    }
                } else {
                    self.showError(string: "Couldn't extract subscription-id from http response",
                                   response: response, dictionary: dictionary)
                }
            } else {
                self.showError(string: "", response: response)
            }
        }
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = self._subID
        
        self.view4CopyLabel.alpha = 0
        self.view4CopyLabel.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.view4CopyLabel.alpha = 1
        }, completion:  { (value: Bool) in
            UIView.animate(withDuration: 0.5, animations: {
                self.view4CopyLabel.alpha = 0
            }, completion: { (value: Bool) in
                self.view4CopyLabel.isHidden = true
            })
        })
    }
    
    @IBAction func applyButtonTapped(_ sender: Any) {
        self.userDefaultsGroup?.setValue(self.bankapp, forKey: "BANKAPP")
        self.userDefaultsGroup?.setValue(self._subID, forKey: "SUBID")
        self.userDefaultsGroup?.setValue(self.bankappString, forKey: "BANKAPPSTRING")
        
        let stringTop = "Begäran lyckades"
        let stringBottom = "Koden tillämpades"
        
        if self._subID != "ExampleXX2GCi3333YpupYBDZX75sOme8Ht9dtuFAKE=" {
            main.terminate { dictionary, response in
                let (responseOK, _) = self.responseCheck(errorString: "logout",
                                                                responseString: "Couldn't logout, but the code was set",
                                                                response: response, dictionary: dictionary)
                self.showStartupScreen()
                
                if (responseOK) {
                    DispatchQueue.main.async {
                        self.showUserError(stringTop: stringTop, stringBottom: stringBottom + " och du loggades ut")
                    }
                }
            }
        } else {
            self.showStartupScreen()
            self.showUserError(stringTop: stringTop, stringBottom: stringBottom)
        }
        
    }
    
    
    func startCountdown(seconds: Int, completion: @escaping (Bool?) -> Void) {
        self.timerSeconds = seconds
        myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timerSeconds -= 1
            if self?.timerSeconds == 0 {
                timer.invalidate()
                completion(true)
            }
        }
    }

    deinit {
        // ViewController going away.  Kill the timer.
        myTimer?.invalidate()
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
        self.errorTopLabel.text = stringTop
        self.errorLabel.text = stringBottom
        
        self.showAndHideErrorView()
    }
    
    private func showError(string: String, response: HTTPURLResponse, dictionary: [String: Any] = [:]) {
        
        let apiError = self.getApiError(dictionary: dictionary)
        
        if apiError != "" {
            self.errorTopLabel.text = "HTTP Response code: " + String(response.statusCode)
            self.errorLabel.text = apiError
        } else {
            var errorString = string
            var errorDataString = ""
            if let myerror = response.value(forHTTPHeaderField: "MYERROR") {
                errorString = myerror
            }
            if let mydataerror = response.value(forHTTPHeaderField: "MYDATAERROR") {
                errorDataString = " + " + mydataerror
            }
            
            self.errorTopLabel.text = "HTTP Response code: " + String(response.statusCode)
            self.errorLabel.text = errorString + errorDataString
        }
        
        self.showAndHideErrorView()
    }
    
    private func showAndHideErrorView() {
        self.errorLabelView.alpha = 0
        self.errorLabelView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.errorLabelView.alpha = 1
        }, completion: { (value: Bool) in
            self.startCountdown(seconds: 5) { (bool) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.errorLabelView.alpha = 0
                }, completion: { (value: Bool) in
                    self.errorLabelView.isHidden = true
                })
            }
        })
    }
    
    private func openBankID() {
        
        let url = URL(string: "https://app.bankid.com/?redirect=swedbankwidget://?sourceApplication=bankid")
        UIApplication.shared.open(url!, options: [.universalLinksOnly:true]) { (success) in
            // handle success/failure
            if (!success) {
                self.showUserError(stringTop: "Ett fel inträffade",
                                   stringBottom: "Du har inte BankID-appen installerad. Kontakta din internetbank.")
            } else {
                self.didOpenBankID = true
            }
        }
    }
    
    private func showStartupScreen() {
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = true
        view4.isHidden = true
        startupView.isHidden = false
        setView.isHidden = true
        
        if let bankAPP = self.userDefaultsGroup?.value(forKey: "BANKAPPSTRING") as? String {
            self.startUpBankLabel.text = "Din valda bank: " + bankAPP
        } else {
            self.startUpBankLabel.text = "Din valda bank: "
        }
        if let subscriptionId = self.userDefaultsGroup?.value(forKey: "SUBID") as? String {
            self.startUpIDLabel.text = "Din valda premunerationskod: " + subscriptionId.prefix(7) + "..."
        } else {
            self.startUpIDLabel.text = "Din valda premunerationskod: "
        }
    }
    
    private func showSetScreen() {
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = true
        view4.isHidden = true
        startupView.isHidden = true
        setView.isHidden = false
    }
    
    private func showFirstScreen() {
        view1.isHidden = false
        view2.isHidden = true
        view3.isHidden = true
        view4.isHidden = true
        startupView.isHidden = true
        setView.isHidden = true
    }
    
    private func showSecondScreen() {
        view1.isHidden = true
        view2.isHidden = false
        view3.isHidden = true
        view4.isHidden = true
        startupView.isHidden = true
        setView.isHidden = true
    }
    
    private func showThirdScreen() {
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = false
        view4.isHidden = true
        startupView.isHidden = true
        setView.isHidden = true
    }
    
    private func showFourthScreen() {
        view1.isHidden = true
        view2.isHidden = true
        view3.isHidden = true
        view4.isHidden = false
        startupView.isHidden = true
        setView.isHidden = true
    }
}

extension UITextView {

    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }

}

