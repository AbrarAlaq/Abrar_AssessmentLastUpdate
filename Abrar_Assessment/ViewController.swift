//
//  ViewController.swift
//  Abrar_Assessment
//
//  Created by ابرار on 23/10/1442 AH.
//

import UIKit
import SwiftWebSocket
import CoreData

class ViewController: UIViewController {
    var socket : WebSocket!
    
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var Connection: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if InternetConnectionManager.isConnectedToNetwork(){
            send.backgroundColor = .blue
            send.isEnabled = true
            Connection.setTitle("diConnect", for: .normal)
        }else{
            send.backgroundColor = .lightGray
            Connection.setTitle("Connect", for: .normal)
            send.isEnabled = false
        }
        send.layer.cornerRadius = 5
        send.layer.borderWidth = 1
        send.layer.borderColor = UIColor.lightGray.cgColor
        socket = WebSocket("wss://echo.websocket.org")
        
        socket.event.open = {
            print("opened" , self.socket.readyState )
        }
         
        socket.event.close = { code, reason, clean in
            print("closed")
        }
         
        socket.event.error = { error in
            print("error \(error)")
        }
         
        socket.event.message = { message in
            if let text = message as? String {
                self.handleMessage(jsonString: text)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    
    func handleMessage(jsonString:String){
            if let data = jsonString.data(using: String.Encoding.utf8){
                do {
                    let JSON : [String:AnyObject] = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                    print("We've successfully parsed the message into a Dictionary! Yay!\n\(JSON)")
                  //  let sender : String = JSON["name"] as! String
                    let message : String = JSON["message"] as! String
                    let time : String = JSON["time"] as! String
     
                    let alert = UIAlertController(title: "Message!", message: "(\(time)): \(message)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } catch let error{
                    print("Error parsing json: \(error)")
                }
            }
     
        }
   
    
    @IBAction func connectOrDisconnect(_ sender: Any) {
       
        if (socket.readyState == .open || socket.readyState == .connecting ){
            
            socket.close()
            print(socket.readyState , "test5")
           Connection.setTitle("Connect", for: .normal)
            send.isEnabled = false
            send.backgroundColor = .lightGray
            
            
        }else {
    if(InternetConnectionManager.isConnectedToNetwork()){
            socket.open()
            Connection.setTitle("diConnect", for: .normal)
            print(socket.readyState , "test6")
            send.isEnabled = true
            send.backgroundColor = .blue
    }
        }
    }
    
    @IBAction func sendTapped(sender: AnyObject) {
        var json = [String:AnyObject]()
        //json["name"] = nameField.text
        json["message"] = messageField.text! as String as AnyObject
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        json["time"] = dateFormatter.string(from: NSDate() as Date) as AnyObject
     
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted);
            if let string = String(data: jsonData, encoding: String.Encoding.utf8){
                socket.send(string)
            } else {
                print("Couldn't create json string");
            }
        } catch let error {
            print("Couldn't create json data: \(error)");
        }
    }
}

