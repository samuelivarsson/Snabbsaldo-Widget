//
//  Swedbank_WidgetApp.swift
//  WatchApp WatchKit Extension
//
//  Created by Samuel Ivarsson on 2022-04-10.
//  Copyright © 2022 Samuel Ivarsson. All rights reserved.
//

import SwiftUI

@main
struct Swedbank_WidgetApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
