//
//  HomeController.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 10/20/20.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "LandscaperAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

protocol HomeControllerDelegate: class {
    func handleMenuToggle()
}


class HomeController: UIViewController {
    
    
    //MARK: - Properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let inputActivationView = LocationInputActivationView()
    private let skapeActionView = SkapeActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var savedProperties = [MKPlacemark]()
    private final let locationInputViewHeight: CGFloat = 200
    private final let skapeActionViewHeight: CGFloat = 300
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    weak var delegate: HomeControllerDelegate?
    
    var user: User? {
        didSet { locationInputView.user = user
            if user?.accountType == .homeowner {
                fetchLandscapers()
                configureLocationInputActivationView()
                observeCurrentJob()
                configureSavedUserProperties()
            } else {
                observeJobs()
            }
        }
    }
    
    private var job: Job? {
        didSet {
            guard let user = user.self else { return }
            
            if user.accountType == .landscaper {
                guard let job = job else { return }
                let controller = JobController(job: job)
                controller.modalPresentationStyle = .fullScreen
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            } else {
                print("DEBUG: Show ride action view for accepted trip..")
            }
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        configureUI()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        guard let job = job else { return }
//        print("DEBUG: Job state is \(job.state)")
//    }
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            delegate?.handleMenuToggle()
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateSkapeActionView(shouldShow: false)
            }
        }
    }
    
    //MARK: - Homeowner API
    
    func observeCurrentJob() {
        HomeownerService.shared.observeCurrentJob { job in
            self.job = job
            guard let state = job.state else { return }
            guard let landscaperUid = job.landscaperUid else { return }

            switch state {
            case .requested:
                break
            case .denied:
                self.shouldPresentLoadingView(false)
                self.presentAlertController(withTitle: "Oops",
                                            message: "It looks like we couldn't find you a skape. Please try again..")
                HomeownerService.shared.deleteJob { (err, ref) in
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.removeAnnotationsAndOverlays()
                }
            case .accepted:
                self.shouldPresentLoadingView(false)
                self.removeAnnotationsAndOverlays()
                self.zoomForActiveJob(withLandscaperUID: landscaperUid)
                
                Service.shared.fetchUserData(uid: landscaperUid, completion: { landscaper in
                    self.animateSkapeActionView(shouldShow: true, config: .jobAccepted, user: landscaper)
                })
            case .landscaperArrived:
                self.skapeActionView.config = .landscaperArrived
            case .inProgress:
                self.skapeActionView.config = .jobInProgress
            case .completed:
                HomeownerService.shared.deleteJob(completion: { (err, ref) in
                    self.animateSkapeActionView(shouldShow: false)
                    self.centerMapOnUserLocation()
                    self.configureActionButton(config: .showMenu)
                    self.inputActivationView.alpha = 1
                    self.presentAlertController(withTitle: "Job Completed", message: "We hope you enjoyed using skape")
                })
//                self.skapeActionView.config = .endJob
            }
        }
    }
    
    func startJob() {
        guard let job = self.job else { return }
        Service.shared.updateJobState(job: job, state: .inProgress) { (err, ref) in
            guard let user = self.user else { return }
            if user.accountType == .homeowner {
                self.skapeActionView.config = .jobInProgress
                self.removeAnnotationsAndOverlays()
            } else {
                self.skapeActionView.config = .endJob
                self.removeAnnotationsAndOverlays()
            }
            self.mapView.zoomToFit(annotations: self.mapView.annotations)
            //self.mapView.addAnnotationAndSelect(forCoordinate: job.propertyCoordinates)
        }
    }
    
    func fetchLandscapers() {
        guard let location = locationManager?.location else { return }
        HomeownerService.shared.fetchLandscapers(location: location) { (landscaper) in
            guard let coordinate = landscaper.location?.coordinate else { return }
            let annotation = LandscaperAnnotation(uid: landscaper.uid, coordinate: coordinate)
            
            var landscaperIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let landscaperAnno = annotation as? LandscaperAnnotation else { return false }
                    if landscaperAnno.uid == landscaper.uid {
                        landscaperAnno.updateAnnotationPosition(withCoordinate: coordinate)
                        self.zoomForActiveJob(withLandscaperUID: landscaper.uid)
                        return true
                    }
                    return false
                })
            }
            if !landscaperIsVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    //MARK: - Landscaper API
    
    func observeJobs() {
        LandscaperService.shared.observeJobs { job in
            self.job = job
            
        }
    }
    
    func observeCancelledJob(job: Job) {
        LandscaperService.shared.observeJobCancelled(job: job) {
            self.removeAnnotationsAndOverlays()
            self.animateSkapeActionView(shouldShow: false)
            self.centerMapOnUserLocation()
            self.presentAlertController(withTitle: "Oops!", message: "The homeowner has decided to cancel this job. Press OK to continue.")
        }
    }
    
    //MARK: - Helper functions
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configureSavedUserProperties() {
        guard let user = user else { return }
        savedProperties.removeAll()
        
        if let propertyOneLocation = user.propertyOneLocation {
            geocodeAddressString(address: propertyOneLocation)
        }
        
        if let propertyTwoLocation = user.propertyTwoLocation {
            geocodeAddressString(address: propertyTwoLocation)
        }
    }
    
    func geocodeAddressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let clPlacemark = placemarks?.first else { return }
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedProperties.append(placemark)
            self.tableView.reloadData()
        }
    }

    
    func configureUI() {
        configureMapView()
        configureSkapeActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
        configureTableView()
    }
    
    func configureLocationInputActivationView() {
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 1) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    func configureSkapeActionView() {
        view.addSubview(skapeActionView)
        skapeActionView.delegate = self
        skapeActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: skapeActionViewHeight)
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        
        //tableView.backgroundColor = .black
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func animateSkapeActionView(shouldShow: Bool, property: MKPlacemark? = nil, config: SkapeActionViewConfiguration? = nil, user: User? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.skapeActionViewHeight : self.view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            self.skapeActionView.frame.origin.y = yOrigin
        }
        
        if shouldShow {
            guard let config = config else { return }
            if let property = property {
                skapeActionView.property = property
            }
            if let user = user {
                skapeActionView.user = user
            }
            
            skapeActionView.config = config

        }
    }
}

// MARK: - MapView Helper Functions

private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach({ item in
                results.append(item.placemark)
            })
            completion(results)
        }
    }
    
    func generatePolyline(toProperty property: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = property
        request.transportType = .automobile
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withCoordinates coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 25, identifier: "StartJob")
        locationManager?.startMonitoring(for: region)
    }
    
    func zoomForActiveJob(withLandscaperUID uid: String) {
        var annotations = [MKAnnotation]()
        
        self.mapView.annotations.forEach({ (annotation) in
            if let anno = annotation as? LandscaperAnnotation {
                if anno.uid == uid {
                    annotations.append(anno)
                }
            }
            if let userAnno = annotation as? MKUserLocation {
                annotations.append(userAnno)
            }
        })
        self.mapView.zoomToFit(annotations: annotations)
    }
}

//MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else { return }
        guard user.accountType == .landscaper else { return }
        guard let location = userLocation.location else { return }
        LandscaperService.shared.updateLandscaperLocation(location: location)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LandscaperAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "Landscaper Truck 2")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
    
    //MARK: - CLLocationManagerDelegate
    
extension HomeController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("DEBUG: Did start monitoring for region \(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("DEBUG: Landscaper did enter homeowner region..")
        
        guard let job = self.job else { return }
        Service.shared.updateJobState(job: job, state: .landscaperArrived) { (err, ref) in
            self.skapeActionView.config = .startJob
        }
    }
    
    func enableLocationServices() {
        locationManager?.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let accuracyAuthorization = manager.accuracyAuthorization
        switch accuracyAuthorization {
        case .fullAccuracy:
            break
        case .reducedAccuracy:
            break
        default:
            break
        }
    }
}

//MARK: - LocationInputActivationViewDelegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}

//MARK: - LocationInputViewDelegate

extension HomeController: LocationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismissLocationInputView() {
        dismissLocationView {_ in
            UIView.animate(withDuration: 0.5, animations: {
                self.inputActivationView.alpha = 1
            })
        }
    }
}

//MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Properties" : "Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedProperties.count : searchResults.count
    }
    
    func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 0 {
            cell.placemark = savedProperties[indexPath.row]
        }
        
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = indexPath.section == 0 ?
            savedProperties[indexPath.row] : searchResults[indexPath.row]
        
        configureActionButton(config: .dismissActionView)
        
        guard let user = user else { return }
        if user.accountType == .landscaper {
            let property = MKMapItem(placemark: selectedPlacemark)
            generatePolyline(toProperty: property)
        }
        
        dismissLocationView { _ in
            self.mapView.addAnnotationAndSelect(forCoordinate: selectedPlacemark.coordinate)
            let annotations = self.mapView.annotations.filter({ !$0.isKind(of: LandscaperAnnotation.self) })
            self.mapView.zoomToFit(annotations: annotations)
            
            self.animateSkapeActionView(shouldShow: true, property: selectedPlacemark, config: .requestSkape)
        }
    }
}

//MARK: - SkapeActionViewDelegate

extension HomeController: SkapeActionViewDelegate {
    func uploadTrip(_ view: SkapeActionView) {
        guard let propertyCoordinates = view.property?.coordinate else { return }
        
        shouldPresentLoadingView(true, message: "Finding you a Skape..")
        
//        Service.shared.uploadTrip(addressCoordinates, propertyCoordinates: propertyCoordinates) { (err, ref) in
        HomeownerService.shared.uploadTrip(propertyCoordinates) { (err, ref) in
            if let error = err {
                print("DEBUG: Failed to upload job with error \(error)")
                return
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                self.skapeActionView.frame.origin.y = self.view.frame.height
            })
        }
    }
    
    func cancelSkape() {
        HomeownerService.shared.deleteJob { (error, ref) in
            if let error = error {
                print("DEBUG: Error deleting job \(error.localizedDescription)")
                return
            }
            self.centerMapOnUserLocation()
            self.animateSkapeActionView(shouldShow: false)
            self.removeAnnotationsAndOverlays()
            
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
            
            self.inputActivationView.alpha = 1
        }
    }
    
    func beginJob() {
        startJob()
    }
    
    func finishJob() {
        guard let job = self.job else { return }
        LandscaperService.shared.updateJobState(job: job, state: .completed) { (err, ref) in
            self.removeAnnotationsAndOverlays()
            self.centerMapOnUserLocation()
            self.animateSkapeActionView(shouldShow: false)
        }
    }
}

//MARK: - JobControllerDelegate

extension HomeController: JobControllerDelegate {
    func didAcceptJob(_ job: Job) {
        self.job = job
        
        self.mapView.addAnnotationAndSelect(forCoordinate: job.propertyCoordinates)
        
        setCustomRegion(withCoordinates: job.propertyCoordinates)
        
        guard let user = user else { return }
        if user.accountType == .landscaper {
            let placemark = MKPlacemark(coordinate: job.propertyCoordinates)
            let mapItem = MKMapItem(placemark: placemark)
            generatePolyline(toProperty: mapItem)
        }
        
        mapView.zoomToFit(annotations: mapView.annotations)
        
//        animateSkapeActionView(shouldShow: true)
        
        observeCancelledJob(job: job)
        
        self.dismiss(animated: true) {
            Service.shared.fetchUserData(uid: job.homeownerUid, completion: { homeowner in
                self.animateSkapeActionView(shouldShow: true, config: .jobAccepted, user: homeowner)
            })
        }
    }
}
