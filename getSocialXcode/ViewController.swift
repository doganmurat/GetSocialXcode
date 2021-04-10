//
//  ViewController.swift
//  getSocialXcode
//
//  Created by murat on 9.04.2021.
//

import UIKit
import Foundation

class ViewController: UIViewController, UITableViewDataSource {
    
    var events = [Event]()
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource=self

    }
    
    
    
    @IBAction func buttonClick(_ sender: UIButton) {
        parseData()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = events[indexPath.row].name
        return cell!
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
    let status, locale, name, eventDescription: String
    let webURI: String
    let hideEventDate, hideEventTime: Bool
    let timezone: String
    let currencyCode: String
    enum CodingKeys: String, CodingKey {
        case id, status, locale, name
        case eventDescription = "description"
        case webURI, hideEventDate, hideEventTime, timezone, currencyCode
    }
}
