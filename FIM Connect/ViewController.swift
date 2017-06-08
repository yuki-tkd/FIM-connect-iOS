//
//  ViewController.swift
//  FIM Connect
//
//  Created by Yuki Takeda on 2017/05/05.
//  Copyright © 2017年 Yuki Takeda. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import Starscream
import SwiftyJSON

class ViewController: UIViewController, UNUserNotificationCenterDelegate, WebSocketDelegate {
    @IBOutlet weak var webview: UIWebView!
    var socket: WebSocket!
    var host: String = "133.16.123.101"
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let wsUrl: String = "ws://" + self.host
        socket = WebSocket(url: URL(string: wsUrl)!, protocols: ["json"])
        socket.delegate = self
        socket.connect()
        
        //Check notification permission
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {
            (granted, error) in
            if error != nil {
                return
            }
            
            if granted {
                debugPrint("通知許可")
            } else {
                debugPrint("通知拒否")
            }
        })
        
        loadAddressURL()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    //WebSocket!!!!!!!!!!!!!!!!!!!!!!
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected:")
    }
   
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        
        let dataFromString = text.data(using: String.Encoding.utf8)
        let json = JSON(data: dataFromString!)
        
        debugPrint(json[0]["status"])
        
        let status = json[0]["status"]
        let roomNumber = json[0]["room_number"]
        let name = json[0]["name"]
        
        self.triggerNotification(
            title: "Room " + String(describing: roomNumber) + " Active",
            body: "Room " + String(describing: roomNumber) + " " + String(describing: name) + " is moving"
        )
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func triggerNotification(title: String, body: String) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // UNMutableNotificationContent 作成
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        
        // identifier, content, trigger から UNNotificationRequest 作成
        let request = UNNotificationRequest.init(identifier: "Notification", content: content, trigger: nil)
        
        // UNUserNotificationCenter に request を追加
        center.add(request)
    }
    
    func loadAddressURL() {
        let url: String = "http://" + self.host + "/demo"
        let requestUrl = URL(string: url)
        let req = NSURLRequest(url: requestUrl!)
        webview.loadRequest(req as URLRequest)
        
    }
}

