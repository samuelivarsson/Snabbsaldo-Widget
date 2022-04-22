//
//  SaldoComplication.swift
//  WatchApp WatchKit Extension
//
//  Created by Samuel Ivarsson on 2022-04-10.
//  Copyright © 2022 Samuel Ivarsson. All rights reserved.
//

import SwiftUI
import ClockKit

let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.samuelivarsson.Swedbank-Widget")!

struct SaldoComplication {
    let saldo: CLKSimpleTextProvider = CLKSimpleTextProvider(text: true ? "1237,39 SEK" : (userDefaults.string(forKey: "GDBelopp") ?? ""))
    let lastUpdate: CLKSimpleTextProvider = CLKSimpleTextProvider(text: "Senast uppdaterad: 19:24")
}

struct SaldoComplication_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CLKComplicationTemplateGraphicCornerStackText(
                innerTextProvider: SaldoComplication().saldo,
                outerTextProvider: CLKSimpleTextProvider(text: "")
            ).previewContext()
        }
    }
}
