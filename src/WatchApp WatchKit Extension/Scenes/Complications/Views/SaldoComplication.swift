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

struct SaldoComplication: View {
    
    let saldo: String = true ? "1237,39 SEK" : (userDefaults.string(forKey: "GDBelopp") ?? "")
    var body: some View {
        if saldo.isEmpty {
            Image(systemName: "gamecontroller")
        } else {
            VStack {
                Text(saldo).font(Font.system(size: 15))
            }
        }
    }
}

struct SaldoComplication_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SaldoComplication()
            CLKComplicationTemplateGraphicCornerCircularView(
                SaldoComplication()
            ).previewContext()
        }
    }
}
