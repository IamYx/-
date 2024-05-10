//
//  TodayWidgetBundle.swift
//  TodayWidget
//
//  Created by 姚肖 on 2023/7/14.
//

import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 16.2, *)
@main
struct TodayWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        TodayWidgetLiveActivity()
    }
}
