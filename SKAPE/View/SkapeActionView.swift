//
//  SkapeActionView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 11/18/20.
//

import UIKit
import MapKit

protocol SkapeActionViewDelegate: class {
//    func presentLocationInputView()
    func uploadTrip(_ view: SkapeActionView)
    func cancelSkape()
    func beginJob()
    func finishJob()
}

enum SkapeActionViewConfiguration {
    case requestSkape
    case jobAccepted
    case landscaperArrived
    case startJob
    case jobInProgress
    case endJob
    
    init() {
        self = .requestSkape
    }
}

enum ButtonAction: CustomStringConvertible {
    case requestSkape
    case cancel
    case getDirections
    case start
    case finish
    
    var description: String {
        switch self {
        case .requestSkape: return "Confirm skape"
        case .cancel: return "Cancel skape"
        case .getDirections: return "Get Directions"
        case .start: return "Start Job"
        case .finish: return "End Job"
        }
    }
    
    init() {
        self = .requestSkape
    }
}

class SkapeActionView: UIView {
    

    //MARK: - Properties
    
    var property: MKPlacemark? {
        didSet {
            titleLabel.text = property?.name
            propertyLabel.text = property?.address
        }
    }
    
    var buttonAction = ButtonAction()
    weak var delegate: SkapeActionViewDelegate?
    var user: User?
    
    var config = SkapeActionViewConfiguration() {
        didSet { configureUI(withConfig: config) }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Is this your property?"
        label.textAlignment = .center
        return label
    }()
    
    private let propertyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
//    private let notMyAddressLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .lightGray
//        label.font = UIFont.systemFont(ofSize: 13)
//        label.text = "This is not my property"
//        label.textAlignment = .center
//        return label
//    }()
    
//    private let propertyButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.backgroundColor = .black
//        button.setTitle("This is not my property", for: .normal)
//        button.backgroundColor = .clear
//        button.layer.cornerRadius = 5
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.mainOrangeTint.cgColor
//        button.setTitleColor(.lightGray, for: .normal)
//        button.titleLabel?.font = UIFont(name: "Avenir-Light", size: 13)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        button.addTarget(self, action: #selector(propertyButtonPressed), for: .touchUpInside)
//        return button
//    }()
    
//    let propertyButton: UIButton = {
//        let button = UIButton(type: .system)
//        let attributedTitle = NSMutableAttributedString(string: "This is not my property", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.lightGray,])
//        button.addTarget(self, action: #selector(propertyButtonPressed), for: .touchUpInside)
//        button.setAttributedTitle(attributedTitle, for: .normal)
//        return button
//    }()
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = UIColor.mainGreenTint
        label.text = ""
        label.skapeActionImage(name: "rsz_skape_website_logo", behindText: true)
//        label.addImageWith(name: "Skape_Website_Logo-1", behindText: false)
        
        view.addSubview(label)
        label.centerX(inView: view)
        label.centerY(inView: view)
        
        return view
    }()
    
    private let skapeTierLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir-Black", size: 25)
        label.textColor = UIColor.mainGreenTint
        label.skapeActionImage(name: "rsz_skape_website_logo", behindText: false)
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.setTitle("Confirm skape", for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.mainGreenTint.cgColor
        button.setTitleColor(.mainGreenTint, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Black", size: 20)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, propertyLabel])
        stack.axis = .vertical
        stack.spacing = 0.25
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(inView: self)
        stack.anchor(top: topAnchor, paddingTop: 12)
        
        addSubview(infoView)
        infoView.centerX(inView: self)
        infoView.anchor(top: stack.bottomAnchor, paddingTop: 50)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 60 / 2
        
//        let separatorView = UIView()
//        separatorView.backgroundColor = .white
//        addSubview(separatorView)
//        separatorView.anchor(top: infoView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 0.75)
        
        addSubview(skapeTierLabel)
        skapeTierLabel.anchor(top: infoView.bottomAnchor, left: leftAnchor, right: rightAnchor)
        skapeTierLabel.centerX(inView: self)
        
        addSubview(actionButton)
        actionButton.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor,
                            right: rightAnchor, paddingLeft: 12,
                            paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch buttonAction {
        case .requestSkape:
            delegate?.uploadTrip(self)
        case .cancel:
            delegate?.cancelSkape()
        case .getDirections:
            print("DEBUG: Get Directions..")
        case .start:
            delegate?.beginJob()
        case .finish:
            delegate?.finishJob()
        }
    }
    
//    @objc func propertyButtonPressed() {
//        self.delegate?.presentLocationInputView()
//    }
    
    //MARK: - Helper Functions
    
    private func configureUI(withConfig config: SkapeActionViewConfiguration) {
        switch config {
        case .requestSkape:
            buttonAction = .requestSkape
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .jobAccepted:
            guard let user = user else { return }
            if user.accountType == .homeowner {
                titleLabel.text = "En Route To Homeowner"
                propertyLabel.text = ""
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                titleLabel.text = "skape En Route"
                propertyLabel.text = ""
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
        case .landscaperArrived:
            guard let user = user else { return }
            if user.accountType == .landscaper {
                titleLabel.text = "Your skape Has Arrived"
                propertyLabel.text = "Please meet landscaper if you have any questions"
            }
        case .startJob:
            titleLabel.text = "Arrived At Property"
            buttonAction = .start
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .jobInProgress:
            guard let user = user else { return }
            if user.accountType == .landscaper {
                actionButton.setTitle("Job In Progress", for: .normal)
                actionButton.isEnabled = false
            }
            else {
                buttonAction = .getDirections
                actionButton.setTitle("Job In Progress", for: .normal)
            }
            
//            titleLabel.text = "En Route to Property"
            
        case .endJob:
            guard let user = user else { return }
            if  user.accountType == .landscaper {
                actionButton.setTitle("Job Ended", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .finish
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
    
//    func configureGestureRecognizer() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(propertyButtonPressed))
//        addGestureRecognizer(tap)
//    }
    
}
