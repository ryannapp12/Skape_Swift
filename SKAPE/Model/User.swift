//
//  User.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 11/15/20.
//

import CoreLocation

enum AccountType: Int {
    case homeowner
    case landscaper
}

struct User {
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    let uid: String
    var propertyOneLocation: String?
    var propertyTwoLocation: String?
    
    var firstInitial: String { return String(fullname.prefix(1)) }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? " "
        
        if let propertyOne = dictionary["propertyOneLocation"] as? String {
            self.propertyOneLocation = propertyOne
        }

        if let propertyTwo = dictionary["propertyTwoLocation"] as? String {
            self.propertyTwoLocation = propertyTwo
        }

        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}

