//
//  TodayWidgetLiveActivity.swift
//  TodayWidget
//
//  Created by 姚肖 on 2023/7/14.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.2, *)
struct TodayWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: TodayWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text(context.state.driverName)
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            
            //灵动岛界面
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.totalAmount)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.orderNumber)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.driverName)
                    Spacer()
                    Text("更多歌曲").foregroundColor(.gray)
                    // more content
                }
            } compactLeading: {
                Text(context.attributes.totalAmount)
            } compactTrailing: {
                Text(context.attributes.orderNumber)
            } minimal: {
                Text(context.attributes.orderNumber)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}
