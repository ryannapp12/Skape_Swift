//
//  Job.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 11/20/20.
//

import CoreLocation

enum JobState: Int {
    case requested
    case denied
    case accepted
    case landscaperArrived
    case inProgress
    case completed
}

struct Job {
//    var addressCoordinates: CLLocationCoordinate2D!
    var propertyCoordinates: CLLocationCoordinate2D!
    let homeownerUid: String!
    var landscaperUid: String?
    var state: JobState!
    
    init(homeownerUid: String, dictionary: [String: Any]) {
        self.homeownerUid = homeownerUid
        
        if let propertyCoordinates = dictionary["propertyCoordinates"] as? NSArray {
            guard let lat = propertyCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = propertyCoordinates[1] as? CLLocationDegrees else { return }
            self.propertyCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        self.landscaperUid = dictionary["landscaperUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = JobState(rawValue: state)
        }
    }
}

