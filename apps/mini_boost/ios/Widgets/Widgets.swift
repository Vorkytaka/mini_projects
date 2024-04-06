//
//  Widgets.swift
//  Widgets
//
//  Created by Konstantin Dovnar on 06.04.2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, goal: 100, current: 60)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = UserDefaults.init(suiteName: "group.tv.vrk.mini.boost")
        let goal = data?.integer(forKey: "goal") ?? 111
        let current = data?.integer(forKey: "current") ?? 110
        let entry = SimpleEntry(date: .now, goal: goal, current: current)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let goal: Int
    let current: Int
}

struct WidgetsEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.goal > 0 {
            let color = Color(red: 0.1294117647, green: 0.6235294118, blue: 0.9529411765)
            let backgroundColor = color.opacity(0.2)
            
            ZStack(alignment: .center) {
                Circle()
                    .stroke(backgroundColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                Circle()
                    .trim(from: 0.0, to: 1.0 - CGFloat(entry.current) / CGFloat(entry.goal))
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("\(entry.current)")
                        .font(.largeTitle)
                        .foregroundColor(color)
                        .fontWeight(.bold)
                    Text("/\(entry.goal)")
                        .font(.body)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                }
            }
        } else {
            Text("Установите\nцель")
                .font(.system(size: 22))
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
    }
}

struct Widgets: Widget {
    let kind: String = "Widgets"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Boostани")
        .description("Следи за прогрессом где угодно.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    Widgets()
} timeline: {
    SimpleEntry(date: .now, goal: 100, current: 60)
}
