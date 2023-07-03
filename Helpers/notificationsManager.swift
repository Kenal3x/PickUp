//
//  notificationsManager.swift
//  PickupProject
//
//  Created by Ken Alexopoulos on 8/23/21.
//

import Foundation
import UserNotifications

class notificationsManager {
    static let shared = notificationsManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert, .provisional]) { (granted, error) in
            
            guard granted else { return }
            print(granted)
            self.getNotificationSettings()
            
        }
    }
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print(settings)
        }
    }
    func scheduleNotification(notificationType:String) {

                let content = UNMutableNotificationContent()
                content.title = notificationType
                content.body = "Notification example"
                content.sound = UNNotificationSound.defaultCritical
                content.badge = 1

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
                let identifier = "Local Notification"

                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                notificationCenter.add(request) { (error) in
                    guard let error = error else { return }
                    print(error.localizedDescription)
                }
            }
    
    
}
