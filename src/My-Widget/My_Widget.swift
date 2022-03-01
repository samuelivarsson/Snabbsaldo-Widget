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

let deeplinkURL: String = "com.samuelivarsson.Swedbank-Widget://"

struct Provider: IntentTimelineProvider {
    
    let userDefaults: UserDefaults = UserDefaults(suiteName: "group.com.samuelivarsson.Swedbank-Widget")!
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dispBelopp: "Disponibelt belopp", belopp: "1239,75 SEK", belopp2: "1238,74 SEK", belopp3: "1235,43 SEK", expMessage: "", waitText: "", info: "", primary: true)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), dispBelopp: "Disponibelt belopp", belopp: "1239,75 SEK", belopp2: "1238,74 SEK", belopp3: "1235,43 SEK", expMessage: "", waitText: "", info: "", primary: true)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let primary = (configuration.Typ == .primary) ? true : false
        updateBalance(primary: primary) {
            let currentDate = Date()
//            let hour = Calendar.current.component(.hour, from: currentDate)
            let entryDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
            let primary = (configuration.Typ == .primary) ? true : false
            
            let entry = SimpleEntry(
                date: entryDate,
                dispBelopp: userDefaults.string(forKey: "GDDispBelopp") ?? "",
                belopp: userDefaults.string(forKey: "GDBelopp") ?? "",
                belopp2: userDefaults.string(forKey: "GDBelopp2") ?? "",
                belopp3: userDefaults.string(forKey: "GDBelopp3") ?? "",
                expMessage: userDefaults.string(forKey: "GDExpMessage") ?? "",
                waitText: userDefaults.string(forKey: "GDWaitText") ?? "",
                info: userDefaults.string(forKey: "GDInfo") ?? "",
                primary: primary
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
    let belopp2: String
    let belopp3: String
    let expMessage: String
    let waitText: String
    let info: String
    let primary: Bool
}

struct My_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            if entry.primary {
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
                }.widgetURL(URL(string: deeplinkURL))
            } else {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                    if colorScheme == .dark {
                        Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)
                    }
                    
                    VStack(alignment: .center, spacing: 10) {
                        if entry.expMessage.isEmpty && entry.info.isEmpty {
                            Text("Sparkonto: ").font(.system(size: 13)).bold()
                            Text(entry.belopp2).font(.system(size: 13)).lineLimit(1).allowsTightening(true).minimumScaleFactor(0.3)
                            Text("Fasta kostnader: ").font(.system(size: 13)).bold()
                            Text(entry.belopp3).font(.system(size: 13)).lineLimit(1).allowsTightening(true).minimumScaleFactor(0.3)
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
                    }.padding()
                    HStack(alignment: .center, spacing: 0, content: {
                        Text("Senast uppdaterad: ").font(.system(size: 9))
                        Text(entry.date, style: .time).font(.system(size: 9))
                    }).offset(x: 0, y: 60)
                }).widgetURL(URL(string: deeplinkURL))
            }
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
            }.widgetURL(URL(string: deeplinkURL))
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

@main
struct My_Widget: Widget {
    let kind: String = "My_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            My_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Snabbsaldo")
        .description("Se ditt saldo snabbt och enkelt.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct My_Widget_Dark_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                dispBelopp: "Disponibelt belopp",
                belopp: "1239,75 SEK",
                belopp2: "1238,74 SEK",
                belopp3: "1235,43 SEK",
                expMessage: "",
                waitText: "",
                info: "",
                primary: false
            )
        )
        .environment(\.colorScheme, .dark)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct My_Widget_Medium_Dark_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                dispBelopp: "Disponibelt belopp",
                belopp: "1239,75 SEK",
                belopp2: "1238,74 SEK",
                belopp3: "1235,43 SEK",
                expMessage: "",
                waitText: "",
                info: "",
                primary: true
            )
        )
        .environment(\.colorScheme, .dark)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

struct My_Widget_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                dispBelopp: "Disponibelt belopp",
                belopp: "1239,75 SEK",
                belopp2: "1238,74 SEK",
                belopp3: "1235,43 SEK",
                expMessage: "",
                waitText: "",
                info: "",
                primary: true
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct My_Widget_Medium_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                dispBelopp: "Disponibelt belopp",
                belopp: "1239,75 SEK",
                belopp2: "1238,74 SEK",
                belopp3: "1235,43 SEK",
                expMessage: "",
                waitText: "",
                info: "",
                primary: true
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
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
