//
//  JobController.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 11/20/20.
//

import UIKit
import MapKit

protocol JobControllerDelegate: class {
    func didAcceptJob(_ job: Job)
}

class JobController: UIViewController {
    
    //MARK: - Properties
    
    weak var delegate: JobControllerDelegate?
    private let mapView = MKMapView()
    let job: Job
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 360, height: 360)
        let cp = CircularProgressView(frame: frame)
        
        cp.addSubview(mapView)
        mapView.setDimensions(height: 268, width: 268)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "x.png").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let jobLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to accept this skape?"
        label.font = UIFont(name: "Avenir-Black", size: 16)
        label.textColor = .black
        return label
    }()
    
    private let acceptJobButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleAcceptJob), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitle("Accept skape", for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mainGreenTint.cgColor
        button.setTitleColor(.mainGreenTint, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 20)
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(job: Job) {
        self.job = job
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selectors
    
    @objc func handleAcceptJob() {
        LandscaperService.shared.acceptJob(job: job) { (error, ref) in
           self.delegate?.didAcceptJob(self.job)
        }
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(duration: 60, value: 0) {
//            LandscaperService.shared.updateJobState(job: self.job, state: .denied) { (err, ref) in
//                self.dismiss(animated: true, completion: nil)
//            }

        }
    }
    
//    @objc func handleDismissal() {
//        dismiss(animated: true, completion: nil)
//    }
    
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
        LandscaperService.shared.updateJobState(job: self.job, state: .denied) { (err,ref) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    //MARK: - API
    
    //MARK: - Helper Functions
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: job.propertyCoordinates, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: false)
        
        mapView.addAnnotationAndSelect(forCoordinate: job.propertyCoordinates)
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
        view.addSubview(circularProgressView)
        circularProgressView.setDimensions(height: 360, width: 360)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(jobLabel)
        jobLabel.centerX(inView: view)
        jobLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 32)
        
        view.addSubview(acceptJobButton)
        acceptJobButton.anchor(top: jobLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
        
    }
}
