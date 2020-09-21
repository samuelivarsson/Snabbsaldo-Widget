//
//  UpdateWidgetIntentHandler.swift
//  Shortcuts
//
//  Created by Samuel Ivarsson on 2020-09-21.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import Foundation
import Intents
import WidgetKit

class UpdateWidgetIntentHandler: NSObject, UpdateWidgetIntentHandling {
    func handle(intent: UpdateWidgetIntent, completion: @escaping (UpdateWidgetIntentResponse) -> Void) {
        WidgetCenter.shared.reloadAllTimelines()
        completion(UpdateWidgetIntentResponse.success(result: "Update success!"))
    }
}
