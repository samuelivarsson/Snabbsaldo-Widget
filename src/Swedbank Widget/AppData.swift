//
//  AppData.swift
//  Swedbank Widget
//
//  Created by Samuel Ivarsson on 2020-01-06.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation

class AppData {
    
    private static var appData: [String: [String: String]] = [
        "swedbank"           : ["appID": "R2S7gO3t2SgvJXUu", "useragent": "SamuelIvarssonWidgetApp"],
        "sparbanken"         : ["appID": "8Pqhy0yI14Gar1b0", "useragent": "SamuelIvarssonWidgetApp"],
        "swedbank_ung"       : ["appID": "HnWVnvxpjYc2DM7g", "useragent": "SamuelIvarssonWidgetApp"],
        "sparbanken_ung"     : ["appID": "BXTU4hqHicC7j0Yq", "useragent": "SamuelIvarssonWidgetApp"],
        "swedbank_foretag"   : ["appID": "9H5GZZAW2DrlLIDH", "useragent": "SamuelIvarssonWidgetApp"],
        "sparbanken_foretag" : ["appID": "Y84LXZMn5xjPabXP", "useragent": "SamuelIvarssonWidgetApp"]
        ]
    
    public static func bankAppId(bankApp: String) -> [String: String] {
        if (appData[bankApp] == nil) {
            print("Bank type does not exists")
            exit(1)
        }
        return appData[bankApp]!
    }
}
