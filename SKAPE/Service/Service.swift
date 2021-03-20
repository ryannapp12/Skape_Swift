//
//  Service.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 11/15/20.
//

import Firebase
import CoreLocation
import GeoFire

//MARK: - DatabaseRefs

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_LANDSCAPERS_LOCATIONS = DB_REF.child("Landscaper-locations")
let REF_JOBS = DB_REF.child("Jobs")

//MARK: - LandscaperService

struct LandscaperService {
    static let shared = LandscaperService()
    
    func observeJobs(completion: @escaping(Job) -> Void) {
        REF_JOBS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let job = Job(homeownerUid: uid, dictionary: dictionary)
            completion(job)
        }
    }
    
    func observeJobCancelled(job: Job, completion: @escaping() -> Void) {
        REF_JOBS.child(job.homeownerUid).observeSingleEvent(of: .childRemoved) { _ in
            completion()
        }
    }
    
    func acceptJob(job: Job, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["landscaperUid": uid, "state": JobState.accepted.rawValue] as [String : Any]
        REF_JOBS.child(job.homeownerUid).updateChildValues(values, withCompletionBlock: completion)
        
    }
    
    func updateJobState(job: Job, state: JobState,
                         completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_JOBS.child(job.homeownerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if state == .completed {
            REF_JOBS.child(job.homeownerUid).removeAllObservers()
        }
        
        if state == .denied {
            REF_JOBS.child(job.homeownerUid).removeAllObservers()
        }
    }
    
    func updateLandscaperLocation(location: CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_LANDSCAPERS_LOCATIONS)
        geofire.setLocation(location, forKey: uid)
    }
}

//MARK: - HomeownerService

struct HomeownerService {
    static let shared = HomeownerService()
    
    func fetchLandscapers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_LANDSCAPERS_LOCATIONS)
        
        REF_LANDSCAPERS_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                Service.shared.fetchUserData(uid: uid, completion: { (user) in
                    var landscaper = user
                    landscaper.location = location
                    completion(landscaper)
                })
            })
        }
    }
    
    //    func uploadTrip(_ addressCoordinates: CLLocationCoordinate2D, _ propertyCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void ) {
        func uploadTrip( _ propertyCoordinates: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void ) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
    //        let addressArray = [addressCoordinates.latitude, addressCoordinates.longitude]
            
            let propertyArray = [propertyCoordinates.latitude, propertyCoordinates.longitude]
            
            let values = ["propertyCoordinates": propertyArray, "state": JobState.requested.rawValue] as [String : Any]
            
    //        let values = ["addressCoordinates": addressArray, "propertyCoordinates": propertyArray, "state": JobState.requested.rawValue] as [String : Any]
            
            REF_JOBS.child(uid).updateChildValues(values, withCompletionBlock: completion)
        }
    
    func observeCurrentJob(completion: @escaping(Job) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_JOBS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let job = Job(homeownerUid: uid, dictionary: dictionary)
            completion(job)
            
        }
    }
    
    func deleteJob(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_JOBS.child(uid).removeValue(completionBlock: completion)
        
    }
    
    func saveLocation(locationString: String, type: LocationType, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let key: String = type == .propertyOne ? "propertyOneLocation" : "propertyTwoLocation"
        REF_USERS.child(uid).child(key).setValue(locationString, withCompletionBlock: completion)
    }

}

//MARK: - SharedService

struct Service {
    static let shared = Service()
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    func updateJobState(job: Job, state: JobState, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_JOBS.child(job.homeownerUid).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        
        if state == .completed {
            REF_JOBS.child(job.homeownerUid).removeAllObservers()
        }
        
        if state == .denied {
            REF_JOBS.child(job.homeownerUid).removeAllObservers()
        }
    }
}
