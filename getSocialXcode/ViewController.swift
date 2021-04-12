//
//  ViewController.swift
//  getSocialXcode
//
//  Created by murat on 9.04.2021.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var events = [Event]()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self
        tableView.delegate=self
        title = "Get Social"
    }
    
    
    
    @IBAction func buttonClick(_ sender: UIButton) {
        parseData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let id = events[indexPath.row].id
        let vc = storyboard?.instantiateViewController(identifier: "second") as! SecondViewController
        vc.id = id
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let eventCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        
        eventCell.eventName.text = events[indexPath.row].name
        eventCell.eventPrice.text = String(events[indexPath.row].ticketInfo.minListPrice) + "$"
        eventCell.eventDate.text = events[indexPath.row].eventDateLocal
        eventCell.eventVenueName.text = events[indexPath.row].venue.name + " /"
        eventCell.eventVenueCity.text = events[indexPath.row].venue.city
        
        return eventCell
    }
    func parseData(){
        let text: String = textField.text!
        let rowCount = 500
        events = []
        
        let url = URL(string:  "https://api.stubhub.com/sellers/search/events/v3?rows=\(rowCount)&city=\(text)")
        
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
                                    self.tableView.reloadData()        }).resume()}
}


    


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)


// MARK: - Welcome
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
