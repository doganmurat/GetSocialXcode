//
//  innerViewController.swift
//  getSocialXcode
//
//  Created by murat on 11.04.2021.
//

import Foundation
import UIKit
import  EventKit
import EventKitUI

class SecondViewController: UIViewController, EKEventViewDelegate {
    var events = [Event]()
    var id: Int?
    let store = EKEventStore()
    
    @IBOutlet weak var innerEventName: UILabel!
    @IBOutlet weak var innerEventDesc: UILabel!
    @IBOutlet weak var innerEventDate: UILabel!
    @IBOutlet weak var innerEventVenueName: UILabel!
    @IBOutlet weak var innerEventVenueCity: UILabel!
    @IBOutlet weak var innerEventPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parseData()
    }
    func eventViewController(_ controller: EKEventViewController, didCompleteWith action: EKEventViewAction) {
        controller.dismiss(animated: true, completion: nil)
        controller.allowsEditing = true
        controller.allowsCalendarPreview = true
       
    }
    
    @IBAction func addYourCalendarClick(_ sender: Any) {
        store.requestAccess(to: .event) { [weak self]  success, error in
            if success, error == nil {
                DispatchQueue.main.async {
                    guard let store = self?.store else {return}
                    
                    let newEvent = EKEvent(eventStore:store)
                    newEvent.title = "Deneme"
                    let otherVC = EKEventEditViewController()
                    otherVC.eventStore = store
                    otherVC.event = newEvent
                    self?.present(otherVC, animated: true)
                    
                }
            }
        }
    }
    
    
    func parseData(){
        events = []
        
        let url = URL(string:  "https://api.stubhub.com/sellers/search/events/v3?id=\(id ?? 0)")
        
        guard url != nil else {
            print("Error")
            return
        }
        
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let header = ["Authorization": "Bearer YzKMJ21JV5zm2Gvsrc89v1YgrvMb","Accept": "application/json"]
        request.allHTTPHeaderFields = header
        request.httpMethod = "GET"
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
        session.dataTask(with: request, completionHandler: {data,response,error in
            guard let data = data, error == nil else {
                return
            }
            var result: Welcome?
            do{
                result = try JSONDecoder().decode(Welcome.self, from: data)
                self.events = result!.events
                
            }
            catch {
                print("failed \(error.localizedDescription)")
            }
            self.title = result?.events[0].name
            self.innerEventName?.text = self.events[0].name
            self.innerEventDesc?.text = self.events[0].eventDescription
            self.innerEventPrice?.text = String(self.events[0].ticketInfo.minListPrice)
            self.innerEventDate?.text = self.events[0].eventDateLocal
            self.innerEventVenueName?.text = self.events[0].venue.name
            self.innerEventVenueCity?.text = self.events[0].venue.city
        }).resume()}
}
