//
//  My_Widget.swift
//  My-Widget
//
//  Created by Samuel Ivarsson on 2020-09-20.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents.INIntents

let deeplinkURLprim: String = "com.samuelivarsson.Swedbank-Widget://prim"
let deeplinkURLsec: String = "com.samuelivarsson.Swedbank-Widget://sec"

let exampleEntry: SimpleEntry = SimpleEntry(
    date: Date(),
    dispBelopp: "Disponibelt belopp",
    belopp: "1239,75 SEK",
    expMessage: "",
    waitText: "",
    info: ""
)

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        exampleEntry
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        completion(exampleEntry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        updateBalance(primary: true) {
            let currentDate = Date()
//            let hour = Calendar.current.component(.hour, from: currentDate)
            let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
            
            saveSaldoData(date: entryDate)
            
            let entry = SimpleEntry(
                date: saldoData.lastUpdate,
                dispBelopp: saldoData.dispBelopp,
                belopp: saldoData.belopp,
                expMessage: saldoData.expMessage,
                waitText: saldoData.waitText,
                info: saldoData.info
            )
            
//            var refreshDate = Calendar.current.date(
//                byAdding: .hour,
//                value: 3,
//                to: currentDate
//            )!
//            if  hour > 22 {
//                refreshDate = getTomorrowAt(hour: 9, minutes: 0)
//            } else if hour < 9 {
//                refreshDate = getTodayAt(hour: 9, minutes: 0)
//            }
            
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dispBelopp: String
    let belopp: String
    let expMessage: String
    let waitText: String
    let info: String
}

struct My_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
                VStack(alignment: .center, spacing: 10) {
                    if entry.expMessage.isEmpty && entry.info.isEmpty {
                        Text(entry.dispBelopp).font(.system(size: 13))
                        Text(entry.belopp).font(.system(size: 22)).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.3)
                    } else {
                        Text(entry.expMessage).font(.system(size: 8)).bold().multilineTextAlignment(.center)
                    }
                    if !entry.info.isEmpty {
                        Text(entry.info).font(.system(size: 7)).bold().multilineTextAlignment(.center)
                    }
                    if !entry.waitText.isEmpty {
                        Text(entry.waitText).font(.system(size: 7))
                            .bold().multilineTextAlignment(.center)
                    }
                    HStack(alignment: .center, spacing: 0) {
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(entry.date, style: .time).font(.system(size: 9))
                    }
                }.padding()
            }.widgetURL(URL(string: deeplinkURLprim))
        default:
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
                VStack(alignment: .center, spacing: 10) {
                    if entry.expMessage.isEmpty && entry.info.isEmpty {
                        Text(entry.dispBelopp).font(.system(size: 15))
                        Text(entry.belopp).font(.system(size: 24)).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.3)
                    } else {
                        Text(entry.expMessage).font(.system(size: 10)).bold().multilineTextAlignment(.center)
                    }
                    if !entry.info.isEmpty {
                        Text(entry.info).font(.system(size: 9)).bold().multilineTextAlignment(.center)
                    }
                    if !entry.waitText.isEmpty {
                        Text(entry.waitText).font(.system(size: 9)).bold().multilineTextAlignment(.center)
                    }
                    HStack(alignment: .center, spacing: 0) {
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(entry.date, style: .time).font(.system(size: 9))
                    }
                }.padding()
            }.widgetURL(URL(string: deeplinkURLprim))
        }
    }
}

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

struct My_Widget: Widget {
    let kind: String = "prim"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            My_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Snabbsaldo")
        .description("Se ditt saldo snabbt och enkelt.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

let exampleSecEntry: SecSimpleEntry = SecSimpleEntry(
    date: Date(),
    belopp2: "1238,74 SEK",
    belopp3: "1235,43 SEK",
    belopp4: "1233,93 SEK",
    expMessage: "",
    waitText: "",
    info: "",
    name2: "",
    name3: "",
    name4: ""
)

struct Sec_Provider: IntentTimelineProvider {
    
    let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.samuelivarsson.Swedbank-Widget")!
    
    func placeholder(in context: Context) -> SecSimpleEntry {
        exampleSecEntry
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SecSimpleEntry) -> ()) {
        completion(exampleSecEntry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        updateBalance(primary: false) {
            let currentDate = Date()
//            let hour = Calendar.current.component(.hour, from: currentDate)
            let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
            
            saveSecSaldoData(date: entryDate)
            
            let entry = SecSimpleEntry(
                date: secSaldoData.lastUpdate,
                belopp2: secSaldoData.belopp2,
                belopp3: secSaldoData.belopp3,
                belopp4: secSaldoData.belopp4,
                expMessage: secSaldoData.expMessage,
                waitText: secSaldoData.waitText,
                info: secSaldoData.info,
                name2: secSaldoData.name2,
                name3: secSaldoData.name3,
                name4: secSaldoData.name4
            )
            
//            var refreshDate = Calendar.current.date(
//                byAdding: .hour,
//                value: 3,
//                to: currentDate
//            )!
//            if  hour > 22 {
//                refreshDate = getTomorrowAt(hour: 9, minutes: 0)
//            } else if hour < 9 {
//                refreshDate = getTodayAt(hour: 9, minutes: 0)
//            }
            
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
        }
    }
}

struct SecSimpleEntry: TimelineEntry {
    let date: Date
    let belopp2: String
    let belopp3: String
    let belopp4: String
    let expMessage: String
    let waitText: String
    let info: String
    let name2: String
    let name3: String
    let name4: String
}

struct Secondary_WidgetEntryView : View {
    var entry: Sec_Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            let titleSize = Font.caption
            let textSize = Font.caption2
            let numberSize = Font.caption2
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
                VStack(alignment: .center, spacing: nil, content: {
                    VStack(alignment: .center, spacing: 5, content: {
                        if entry.expMessage.isEmpty && entry.info.isEmpty {
                            Text("Konto saldon:").font(titleSize).bold()
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name2).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp2).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name3).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp3).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name4).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp4).font(numberSize)
                            })
                        } else {
                            Text(entry.expMessage).font(.system(size: 8)).bold().multilineTextAlignment(.center)
                        }
                        if !entry.info.isEmpty {
                            Text(entry.info).font(.system(size: 7)).bold().multilineTextAlignment(.center)
                        }
                        if !entry.waitText.isEmpty {
                            Text(entry.waitText).font(.system(size: 7))
                                .bold().multilineTextAlignment(.center)
                        }
                    }).frame(maxWidth: .infinity)
                    HStack(alignment: .center, spacing: 0, content: {
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(Date(), style: .time).font(.system(size: 9))
                    }).offset(x: 0, y: 5)
                }).padding()
            }.widgetURL(URL(string: deeplinkURLsec))
        default:
            let titleSize = Font.caption
            let textSize = Font.caption2
            let numberSize = Font.caption2
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                if colorScheme == .dark {
                    Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                }
                
                VStack(alignment: .center, spacing: nil, content: {
                    VStack(alignment: .center, spacing: 5, content: {
                        if entry.expMessage.isEmpty && entry.info.isEmpty {
                            Text("Konto saldon:").font(titleSize).bold()
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name2).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp2).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name3).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp3).font(numberSize)
                            })
                            VStack(alignment: .center, spacing: 1, content: {
                                Text(entry.name4).font(textSize).bold().lineLimit(1).allowsTightening(true).minimumScaleFactor(0.5)
                                Text(entry.belopp4).font(numberSize)
                            })
                        } else {
                            Text(entry.expMessage).font(.system(size: 8)).bold().multilineTextAlignment(.center)
                        }
                        if !entry.info.isEmpty {
                            Text(entry.info).font(.system(size: 7)).bold().multilineTextAlignment(.center)
                        }
                        if !entry.waitText.isEmpty {
                            Text(entry.waitText).font(.system(size: 7))
                                .bold().multilineTextAlignment(.center)
                        }
                    }).frame(maxWidth: .infinity)
                    HStack(alignment: .center, spacing: 0, content: {
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(Date(), style: .time).font(.system(size: 9))
                    }).offset(x: 0, y: 5)
                }).padding()
            }.widgetURL(URL(string: deeplinkURLsec))
        }
    }
}


struct Secondary_Widget: Widget {
    let kind: String = "sec"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Sec_Provider()) { entry in
            Secondary_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Snabbsaldo")
        .description("Se ditt saldo snabbt och enkelt.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

let exampleView: My_WidgetEntryView = My_WidgetEntryView(
    entry: exampleEntry
)

let exampleSecView: Secondary_WidgetEntryView = Secondary_WidgetEntryView(
    entry: exampleSecEntry
)

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Small dark
            exampleView
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Medium dark
            exampleView
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            // Small dark secondary
            exampleSecView
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Small white
            exampleView
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            // Medium white
            exampleView
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

@main
struct SheetsWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        My_Widget()
        Secondary_Widget()
    }
}

func saveSaldoData(date: Date) {
    let userDefaults: UserDefaults = UserDefaults(
        suiteName: "group.com.samuelivarsson.Swedbank-Widget"
    )!
    
    saldoData.lastUpdate = date
    saldoData.belopp = userDefaults.string(forKey: "GDBelopp") ?? ""
    saldoData.dispBelopp = userDefaults.string(forKey: "GDDispBelopp") ?? ""
    saldoData.expMessage = userDefaults.string(forKey: "GDExpMessage") ?? ""
    saldoData.waitText = userDefaults.string(forKey: "GDWaitText") ?? ""
    saldoData.info = userDefaults.string(forKey: "GDInfo") ?? ""
}

func saveSecSaldoData(date: Date) {
    let userDefaults: UserDefaults = UserDefaults(
        suiteName: "group.com.samuelivarsson.Swedbank-Widget"
    )!
    
    secSaldoData.lastUpdate = date
    secSaldoData.belopp2 = userDefaults.string(forKey: "GDBelopp2") ?? ""
    secSaldoData.belopp2 = userDefaults.string(forKey: "GDBelopp2") ?? ""
    secSaldoData.belopp3 = userDefaults.string(forKey: "GDBelopp3") ?? ""
    secSaldoData.belopp4 = userDefaults.string(forKey: "GDBelopp4") ?? ""
    secSaldoData.expMessage = userDefaults.string(forKey: "GDExpMessage") ?? ""
    secSaldoData.waitText = userDefaults.string(forKey: "GDWaitText") ?? ""
    secSaldoData.info = userDefaults.string(forKey: "GDInfo") ?? ""
    secSaldoData.name2 = userDefaults.string(forKey: "SUBNAME2") ?? ""
    secSaldoData.name3 = userDefaults.string(forKey: "SUBNAME3") ?? ""
    secSaldoData.name4 = userDefaults.string(forKey: "SUBNAME4") ?? ""
}

func getTomorrowAt(hour: Int, minutes: Int) -> Date {
    let today = Date()
    let morrow = Calendar.current.date(byAdding: .day,
                                       value: 1,
                                       to: today)
    return Calendar.current.date(bySettingHour: hour,
                                 minute: minutes,
                                 second: 0,
                                 of: morrow!)!

}

func getTodayAt(hour: Int, minutes: Int) -> Date {
    let today = Date()
    return Calendar.current.date(bySettingHour: hour,
                                 minute: minutes,
                                 second: 0,
                                 of: today)!

}
