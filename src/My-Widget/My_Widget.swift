//
//  My_Widget.swift
//  My-Widget
//
//  Created by Samuel Ivarsson on 2020-09-20.
//  Copyright © 2020 Samuel Ivarsson. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    let gd = GetData()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), belopp: "-", info: "-", waitText: "-", dispBelopp: "Disponibelt belopp")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), belopp: "1239,75 SEK", info: "", waitText: "", dispBelopp: "Disponibelt belopp")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        self.gd.getBalance {
            let currentDate = Date()
            let refreshDate = Calendar.current.date(
                byAdding: .minute,
                value: 30,
                to: currentDate
            )!
            let entry = SimpleEntry(
                date: currentDate,
                belopp: gd.belopp,
                info: gd.info,
                waitText: gd.waitText,
                dispBelopp: gd.dispBelopp
            )
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let belopp: String
    let info: String
    let waitText: String
    let dispBelopp: String
}

struct My_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center),
                   content: {
                colorScheme == .dark ?
                    (Color(red: 44/255, green: 44/255, blue: 44/255)
                        .edgesIgnoringSafeArea(.all)) :
                    (Color.white).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 10, content: {
                    Text(entry.dispBelopp).font(.system(size: 13))
                    Text(entry.belopp).font(.system(size: 22)).bold()
                    if (!entry.waitText.isEmpty) {
                        Text(entry.waitText).font(.system(size: 7))
                            .bold().multilineTextAlignment(.center)
                            .padding(.horizontal, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    } else {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("Last updated: ").font(.system(size: 9))
                            Text(entry.date, style: .time).font(.system(size: 9))
                        })
                    }
                })
            })
        default:
            ZStack(alignment: Alignment(horizontal: .center, vertical: .center), content: {
                colorScheme == .dark ?
                    (Color(red: 44/255, green: 44/255, blue: 44/255).edgesIgnoringSafeArea(.all)) :
                    (Color.white).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 10, content: {
                    Text(entry.dispBelopp).font(.system(size: 15))
                    Text(entry.belopp).font(.system(size: 24)).bold()
                    if (!entry.waitText.isEmpty) {
                        Text(entry.waitText).font(.system(size: 9)).bold().multilineTextAlignment(.center)
                    } else {
                        HStack(alignment: .center, spacing: 0, content: {
                            Text("Last updated: ").font(.system(size: 9))
                            Text(entry.date, style: .time).font(.system(size: 9))
                        })
                    }
                })
            })
        }
    }
}

@main
struct My_Widget: Widget {
    let kind: String = "My_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            My_WidgetEntryView(entry: entry)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.green)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct My_Widget_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                belopp: "1239,75 SEK",
                info: "",
                waitText: "",
                dispBelopp: "Disponibelt belopp"
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct My_Widget_Dark_Previews: PreviewProvider {
    static var previews: some View {
        My_WidgetEntryView(
            entry: SimpleEntry(
                date: Date(),
                belopp: "1239,75 SEK",
                info: "",
                waitText: "",
                dispBelopp: "Disponibelt belopp"
            )
        )
        .environment(\.colorScheme, .dark)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
