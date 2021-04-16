//
//  innerViewController.swift
//  getSocialXcode
//
//  Created by murat on 11.04.2021.
//

import LocalAuthentication
import Foundation
import UIKit
import  EventKit
import EventKitUI
import RealmSwift

class SecondViewController: UIViewController, EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction){
        self.dismiss(animated: true, completion: nil)
    }
    
    var events = [Event]()
    var id: Int?
    let realmevents = try! Realm().objects(EventObject.self).sorted(byKeyPath: "eventDateLocal", ascending: true )
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
    
    @IBAction func addYourCalendarClick(_ sender: Any) {
        auth()
    }
    
    func auth(){
        let context = LAContext()
        var error: NSError? = nil
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Please authorize with touch id"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
                DispatchQueue.main.async {
                    guard success, error == nil else{
                        let alert = UIAlertController(title: "Unavailable", message: "You cant use", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self?.present(alert,animated: true)
                        return
                    }
                    self?.eventVC()
                }
            }
    
        }else{
            //
        }
    }
    func eventVC(){
        
        let isoDate = realmevents[id!].eventDateLocal
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)!
        
        
        let store = EKEventStore()
        store.requestAccess(to: .event) { (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        let newEvent = EKEvent(eventStore:store)
                        let otherVC = EKEventEditViewController()
                        otherVC.event = newEvent
                        otherVC.editViewDelegate = self
                        otherVC.eventStore = store
                        self.present(otherVC, animated: true)
                        newEvent.title = self.realmevents[self.id!].name
                        newEvent.startDate = date
                        newEvent.endDate = date
                    }
                }
            return
        }
        
    }
    
    func parseData(){

        title = realmevents[id!].name
        innerEventName?.text = realmevents[id!].name
        innerEventDesc?.text = realmevents[id!].eventDescription
        innerEventPrice?.text = String(realmevents[id!].ticketInfo!.minListPrice)
        innerEventDate?.text = realmevents[id!].eventDateLocal
        innerEventVenueName?.text = realmevents[id!].venue?.name
        innerEventVenueCity?.text = realmevents[id!].venue?.city
    }
}
