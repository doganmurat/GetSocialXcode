//
//  ViewController.swift
//  getSocialXcode
//
//  Created by murat on 9.04.2021.
//

import UIKit
import Foundation
import RealmSwift
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    //
    var events = [Event]()
    let realmevents = try! Realm().objects(EventObject.self).sorted(byKeyPath: "eventDateLocal", ascending: true )
    var manager: CLLocationManager = CLLocationManager()
    //defining ui elements
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        //setting title
        title = "Get Social"
    }
    
    //click event for search button
    @IBAction func buttonClick(_ sender: UIButton) {
        parseData()
        
    }
    
    //setting row height of custom cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //click event for custom cells
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let id = indexPath.row
        let vc = storyboard?.instantiateViewController(identifier: "second") as! SecondViewController
        vc.id = id
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //size of custom cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //checking table is empty or not for useful ui
        if realmevents.count == 0 {
                self.tableView.setEmptyMessage("Search by city name and get social!")
            } else {
                self.tableView.restore()
            }

            return realmevents.count
    }
    
    //setting cell elements
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let eventCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        //date formatter
        let isoDate = realmevents[indexPath.row].eventDateLocal
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        var minute = ""
        if components.minute! == 0{
            minute = "00"
        }else{
            minute = String(components.minute!)
        }
        //defining elements
        eventCell.eventName.text = realmevents[indexPath.row].name
        eventCell.eventDate.text = String(components.year!)+"/"+String(components.month!)+"/"+String(components.day!)+" "+String(components.hour!)+"."+minute
        eventCell.eventPrice.text = String(realmevents[indexPath.row].ticketInfo!.minListPrice)+"$"
        eventCell.eventVenueName.text = realmevents[indexPath.row].venue?.name
        eventCell.eventVenueCity.text = realmevents[indexPath.row].venue?.city
        
        return eventCell
    }
    
    //getting data from json
    func parseData(){
        let text: String = textField.text!
        let rowCount = 50
        events = []					
        
        let url = URL(string:  "https://api.stubhub.com/sellers/search/events/v3?city=\(text)&sort=eventDateLocal%20asc&rows=\(rowCount)")
        
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
                let realm = try! Realm()
                try! realm.write {
                    realm.deleteAll()
                }
                for name in self.events{
                    let ticketInfo = TicketInfoObject(_id: "0", minListPrice: String(name.ticketInfo.minListPrice))
                    let venue = VenueObject(_id: "0", name: name.venue.name, city: name.venue.city, state: name.venue.state, country: name.venue.country, latitude: name.venue.latitude, longitude: name.venue.longitude)
                    let event = EventObject(_id: "0", id: name.id, name: name.name, eventDescription: name.eventDescription, eventDateLocal: name.eventDateLocal, venue: venue, ticketInfo: ticketInfo)
                    try! realm.write{
                        realm.add(event)
                    }
                }
            }
            catch {
                print("failed \(error.localizedDescription)")
            }
            self.tableView.reloadData()
        }).resume()}
}

//extension for empty table
extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

//json structures
struct Welcome: Codable {
    let numFound: Int
   let events: [Event]
    
}
// MARK: - Event
struct Event: Codable {
    let id: Int
    let name, eventDescription: String
    let eventDateLocal: String
    let venue: Venue
    let ticketInfo: TicketInfo
    enum CodingKeys: String, CodingKey {
        case id, name
        case eventDescription = "description"
        case eventDateLocal, venue, ticketInfo
    }
}

// MARK: - TicketInfo
struct TicketInfo: Codable {
    let minListPrice: Double
}

struct Venue: Codable {
    let id: Int
    let name, city, state: String
    let country: String
    let latitude, longitude: Double

    enum CodingKeys: String, CodingKey {
        case id, name, city, state, country
        case latitude, longitude
    }
}





//Realm Objects

final class TicketInfoObject: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var minListPrice = ""
    convenience init(_id:String, minListPrice: String){
        self.init()
        self.minListPrice = minListPrice
    }
}

final class VenueObject: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var name = ""
    @objc dynamic var city = ""
    @objc dynamic var state = ""
    @objc dynamic var country = ""
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    convenience init(_id: String, name: String, city: String, state: String,country: String,latitude: Double, longitude: Double){
        self.init()
        self.city = city
        self.name = name
        self.state = state
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
    
    override class func primaryKey() -> String? {
        return "_id"
    }
    
}


final class EventObject: Object {
    @objc dynamic var _id: ObjectId = ObjectId.generate()
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var eventDescription = ""
    @objc dynamic var eventDateLocal = ""
    @objc dynamic var venue: VenueObject? = nil
    @objc dynamic var ticketInfo: TicketInfoObject? = nil
    
    convenience init(_id: String,id: Int, name: String, eventDescription: String, eventDateLocal: String, venue: VenueObject, ticketInfo: TicketInfoObject){
        self.init()
        self.id = id
        self.name = name
        self.eventDescription = eventDescription
        self.eventDateLocal = eventDateLocal
        self.venue = venue
        self.ticketInfo = ticketInfo
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
}



