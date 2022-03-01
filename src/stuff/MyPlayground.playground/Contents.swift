import UIKit
import CommonCrypto

//enum Banks: String {
//    case swedbank = "Swedbank"
//    case sparbanken = "Sparbanken"
//    case swedbank_foretag = "Swedbank Företag"
//    case sparbanken_foretag = "Sparbanken Företag"
//}
//
//let bankapp = "Swedbank"
//
//if Banks(rawValue: bankapp) == nil {
//    print("hej")
//} else {
//    print("aj")
//}

class myclass {
    
    private var myTimer: Timer?
    private var timerSeconds: Int = 0
    
    func startCountdown(seconds: Int, completion: @escaping (Bool?) -> Void) {
        self.timerSeconds = seconds
        print(self.timerSeconds)
        myTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timerSeconds -= 1
            if self?.timerSeconds == 0 {
                timer.invalidate()
                completion(true)
            } else {
                print(self?.timerSeconds)
            }
        }
    }
}

let mycl = myclass()
mycl.startCountdown(seconds: 5) { (bool) in
    print("Klar")
}

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

private func dsidGen() -> String {
    var dsid = String(Int.random(in: 1...999999)).sha1()
    dsid = String(dsid.suffix(dsid.count-Int.random(in: 1...30)))
    dsid = String(dsid.prefix(8))
    dsid = String(dsid.prefix(4) + dsid.suffix(4).uppercased())
    
    return String(dsid.shuffled())
}

print(dsidGen())
