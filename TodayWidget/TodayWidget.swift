//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by 姚肖 on 2023/7/14.
//

import WidgetKit
import SwiftUI
import Intents
import AppIntents

struct Provider: IntentTimelineProvider {
    // 占位视图，例如网络请求失败、发生未知错误、第一次展示小组件都会展示这个view
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), musicName: "music name", musicPic: UIImage(), count: "\(Counter.currentCount())")
    }
    // 定义Widget预览中如何展示，所以提供默认值要在这里
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        //从主项目获取数据
        let userDefault = UserDefaults(suiteName:"group.com.today.widge")
        let musicName = userDefault?.object(forKey: "MusicName")
        
        let entry = SimpleEntry(date: Date(), configuration: configuration, musicName: musicName as! String, musicPic: UIImage(), count: "\(Counter.currentCount())")
        completion(entry)
    }
    // 决定 Widget 何时刷新
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            //从主项目获取数据
            let userDefault = UserDefaults(suiteName:"group.com.today.widge")
            var musicName = userDefault?.object(forKey: "MusicName")
            var musicPic = userDefault?.object(forKey: "MusicPic")
            
            musicName = (musicName != nil) ? musicName : "music name"
            musicPic = (musicPic != nil) ? musicPic : ""
            var image: UIImage? = nil
            let url = URL(string: musicPic as! String)
            if url != nil {
                let iamgeData = try? Data(contentsOf: url!)
                if iamgeData != nil {
                    image = UIImage(data: iamgeData!)
                }
            }
            
            let entry = SimpleEntry(date: entryDate, configuration: configuration, musicName: musicName as! String, musicPic: (image ?? UIImage.init()), count: "\(Counter.currentCount())")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 渲染 Widget 所需的数据模型，需要遵守TimelineEntry协议
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let musicName : String
    let musicPic : UIImage
    let count: String
}

// 渲染的view
struct TodayWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.scenePhase) private var phase
    @State private var count = 0
    
    var body: some View {
        
        if #available(iOSApplicationExtension 17.0, *) {
            
            @Environment(\.widgetContentMargins) var margins

            VStack {
                Text("Count: \(entry.count)")
                
                HStack {
                    // 交互
                    Button(intent: CountIntent(isIncrement: true)) {
                        Image(systemName: "plus.circle")
                    }
                    
                    Button(intent: CountIntent(isIncrement: false)) {
                        Image(systemName: "minus.circle")
                    }
                }
                .font(.largeTitle)
            }
            .containerBackground(.fill.tertiary, for: .widget) // iOS17新增，设置小组件背景
            .padding(.top, margins.top) // 设置顶部边距
            
        } else {
            //            Text(entry.date, style: .time)
            ZStack(alignment: .bottomTrailing) {
                
                Image(uiImage: entry.musicPic)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text(entry.musicName)
                    .padding(5)
                    .background(Color.black.opacity(0.5))
                    .foregroundColor(.white)
                
            }.widgetURL(URL(string: "today://widgetClick"))
        }
        
    }
}

@available(iOSApplicationExtension 16.0, *)
struct CountIntent: AppIntent {
    
    static var title: LocalizedStringResource = "CountIntent"
    static var description: IntentDescription = IntentDescription("CountIntent")

    // AppIntent的输入参数
    @Parameter(title: "isIncrement")
    var isIncrement: Bool

    init() {
    }

    init(isIncrement: Bool) {
        self.isIncrement = isIncrement
    }

    func perform() async throws -> some IntentResult {
        if isIncrement {
            Counter.incrementCount()
        } else {
            Counter.decrementCount()
        }
        return .result()
    }
}

class Counter {
    @AppStorage("count", store: UserDefaults(suiteName: "Widget2023")) static var count = 0

    static func incrementCount() {
        count += 1
    }

    static func decrementCount() {
        count -= 1
    }

    static func currentCount() -> Int {
        return count
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

// SwiftUI Xcode 测试预览视图
struct TodayWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        //从主项目获取数据
        let userDefault = UserDefaults(suiteName:"group.com.today.widge")
        let musicName = userDefault?.object(forKey: "MusicName")
        var musicPic = userDefault?.object(forKey: "MusicPic")
        
        TodayWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), musicName: musicName as! String, musicPic: UIImage(), count: "\(Counter.currentCount())"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
