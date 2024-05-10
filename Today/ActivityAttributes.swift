//
//  ActivityAttributes.swift
//  MyDemo
//
//  Created by 姚肖 on 2022/11/17.
//

import SwiftUI
import ActivityKit

struct TodayWidgetAttributes: ActivityAttributes {
    
    public typealias PizzaDeliveryStatus = ContentState
    
    // 动态数据
    public struct ContentState: Codable, Hashable {
        var driverName: String
        var deliveryTimer: ClosedRange<Date>
    }
    
    // 静态数据
    var numberOfPizzas: Int
    var totalAmount: String
    var orderNumber: String
    
}
