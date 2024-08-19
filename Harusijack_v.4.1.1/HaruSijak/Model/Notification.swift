/*
    Description : HaruSijack App 개발 notification class
    Date : 2024.6.11
    Author : snr
    Detail :
    Updates :
        * 2024.06.13 by snr : class for notification
        * 2024.06.17 by snr : 설정대 시간대에서 한시간 일찍 알림 뜨도록 설정
        * 2024.06.27 by snr : 지하철 혼잡도 예측 알림 1개만 뜨도록 minute 설정
 */

import SwiftUI
import UserNotifications

struct Notification {
    var id: String
    var title: String
}

class NotificationManager {
    
    var notifications = [Notification]()
    
    //제일 처음 알림설정을 위한 permission 함수
    func requestPermission() {
        // .alert : 알림 띄우기, .sound : 띵! 소리, .badge : 앱 로고 위에 숫자표시
        let options: UNAuthorizationOptions = [.alert, .sound,.badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error{
                print("Error : \(error)")
            } else {
                print("SUCCESS")
            }
        }
    }
    
    func addNotification(title: String) {
        notifications.append(Notification(id: UUID().uuidString, title: title))
    }
    
    func schedule() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .notDetermined: self.requestPermission()
                case .authorized, .provisional: self.scheduleNotifications()
                default : break
            }
        }
    }
    
    func scheduleNotifications() {
        
        let dbModel = TimeSettingDB()
//        let calendarModel = CalendarDB()
        
        for notification in notifications {
            // 날짜 설정
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            // 알림 시간 설정
            print("시간 : ",dbModel.queryDB().first?.time ?? 0)
            dateComponents.hour = (dbModel.queryDB().first?.time ?? 0) - 1 //db에서 저장한 시간에서 한시간 먼저 알려주기*/
            print("dddhour : ", dateComponents.hour!)
            dateComponents.minute = 45
            
            // 현재날짜와 calendar 날짜가 같은지 비교해서 알림표시
//            let currentDate = Date() //오늘날짜에서
//            let todayDate = formattedDate(currentDate: currentDate) //yyyy-MM-dd만 가져옴
            
            let info = dbModel.queryDB().first
            
            let dateFormatterDate = DateFormatter()
            dateFormatterDate.dateFormat = "yyyy-MM-dd"

            // todayDate를 Optional<String>로 선언
            let todate = dateFormatterDate.string(from: Date())

            if let info = info {
                
                fetchDataFromServerBoarding2(stationName: info.station, date: todate, time: String(info.time), stationLine: "7") { response in
                    
                    let ride = Int(self.getValueForCurrentTime(jsonString: response, currentTime: String(info.time))) // 승차인원수 가져오기
                    
                    self.fetchDataFromServerAlighting(stationName: info.station, date: todate, time: String(info.time), stationLine: "7") { response2 in
                        let down = Int(self.getValueForCurrentTime(jsonString: response2, currentTime: String(info.time))) //하차인원수 가져오기
                        
                        
                        let content = UNMutableNotificationContent()
                        content.title = "🔔\(String(info.time-1))시 \(info.station)역의 혼잡도 🔔"
                        content.sound = .default
                        content.subtitle = "승차인원 : \(ride)명, 하차인원 : \(down)명입니다."

                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request) { error in
                            guard error == nil else {return}
                            print("scheduling notification with id:\(notification.id)")
                        }
                    }
                    
                    
                }
                
                
                
            } else {
                print("info is nil")
            }
        }
    }
    
    /* MARK: 날짜 체크 */
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func getValueForCurrentTime(jsonString: String, currentTime: String) -> Double {
        guard let jsonData = jsonString.data(using: .utf8) else { return 0.0 }
        do {
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                let keyForCurrentTime = "\(currentTime)시인원"
                if let value = json[keyForCurrentTime] as? Double {
                    return value
                }
            }
        } catch {
            print("Error parsing JSON:", error)
        }
        return 0.0
    }
    
    /* MARK: yyyy-MM-dd formatter */
    func formattedDate(currentDate: Date) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: formatter.string(from: currentDate))
    }
    
    func cancleNotification() {
        // 곧 다가올 알림 지우기
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        //현재 폰에 떠 있는 알림 지우기
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func deleteBadgeNumber() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
 
    //승차함수
    func fetchDataFromServerBoarding2(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "http://54.180.247.41:5000//subway")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "stationName": stationName,
            "date": date,
            "time": time,
            "stationLine": stationLine
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
                print(responseString)
            }
        }
        task.resume()
    }
    
    //하차함수
    func fetchDataFromServerAlighting(stationName: String, date: String, time: String, stationLine: String, completion: @escaping (String) -> Void) {
        print(stationName,date,time,stationLine)
        let url = URL(string: "http://54.180.247.41:5000/subwayAlighting")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "stationName": stationName,
            "date": date,
            "time": time,
            "stationLine": stationLine
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error:", error ?? "Unknown error")
                
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                completion(responseString)
            }
        }
        task.resume()
    }
}


