//
//  WidgetKitManager.swift
//  Today
//
//  Created by 姚肖 on 2023/7/14.
//

import WidgetKit
import ActivityKit

@objc
@available(iOS 14.0, *)
class WidgetKitManager: NSObject {
    @objc
    static let shareManager = WidgetKitManager()
    
    /// MARK: 刷新所有小组件
    @objc
    func reloadAllTimelines() {
#if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }
    
    /// MARK: 刷新单个小组件
    /*
     kind: 小组件Configuration 中的kind
     */
    @objc
    func reloadTimelines(kind: String) {
#if arch(arm64) || arch(i386) || arch(x86_64)
        WidgetCenter.shared.reloadTimelines(ofKind: kind)
#endif
    }
    
    @objc
    func startLiveAc(name : String) {
        let pizzaDeliveryAttributes = TodayWidgetAttributes(numberOfPizzas: 1, totalAmount:"音乐ing", orderNumber: "stop")
        
        let initialContentState = TodayWidgetAttributes.PizzaDeliveryStatus(driverName: name, deliveryTimer: Date()...Date().addingTimeInterval(15 * 60))
        
        do {
            if #available(iOS 16.1, *) {
                let deliveryActivity = try Activity<TodayWidgetAttributes>.request(
                    attributes: pizzaDeliveryAttributes,
                    contentState: initialContentState,
                    pushType: nil)
            }
        } catch (let error) {
            print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
        }
    }
    
    @objc
    func updateLiveAc(name : String) {
        Task {
            let updatedDeliveryStatus = TodayWidgetAttributes.PizzaDeliveryStatus(driverName: name, deliveryTimer: Date()...Date().addingTimeInterval(15 * 60))
            
            if #available(iOS 16.1, *) {
                for activity in Activity<TodayWidgetAttributes>.activities{
                    await activity.update(using: updatedDeliveryStatus)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @objc
    func stopLiveAc() {
        Task {
            if #available(iOS 16.1, *) {
                for activity in Activity<TodayWidgetAttributes>.activities{
                    await activity.end(dismissalPolicy: .immediate)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
}
