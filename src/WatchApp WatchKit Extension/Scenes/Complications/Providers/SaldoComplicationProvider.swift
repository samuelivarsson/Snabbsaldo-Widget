//
//  SaldoComplicationProvider.swift
//  WatchApp WatchKit Extension
//
//  Created by Samuel Ivarsson on 2022-04-10.
//  Copyright © 2022 Samuel Ivarsson. All rights reserved.
//

import Foundation
import SwiftUI
import ClockKit

final class SaldoComplicationProvider {
    func getSaldoComplication() -> CLKComplicationTemplate {
        let sc = SaldoComplication()
        return CLKComplicationTemplateGraphicCornerStackText(
            innerTextProvider: sc.saldo,
            outerTextProvider: CLKSimpleTextProvider(text: "")
        )
    }
}
