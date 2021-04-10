//
//  ViewController.swift
//  getSocialXcode
//
//  Created by murat on 9.04.2021.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        
        let url = URL(string:  "https://api.stubhub.com/sellers/search/events/v3")
        
        guard url != nil else {
            print("Error")
            return
        }
        
        var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        
        let header = ["Authorization": "Bearer YzKMJ21JV5zm2Gvsrc89v1YgrvMb","Accept": "application/json"]
        request.allHTTPHeaderFields = header
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
            guard let data = data, error == nil else {
                return
            }
            var result: Welcome?
            do{
                result = try JSONDecoder().decode(Welcome.self, from: data)
                }
            catch {
                print("failed \(error.localizedDescription)")
            }
            
            guard let json = result else{
                return
            }
            print(json.numFound)
            
        }).resume()
            
    }
    
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
