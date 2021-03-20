//
//  LocationInputView.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 10/27/20.
//

import UIKit

protocol LocationInputViewDelegate: class {
    func dismissLocationInputView()
    func executeSearch(query: String)
}

class LocationInputView: UIView {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            //skapeLabel.text = user?.fullname
        }
    }
    
    weak var delegate: LocationInputViewDelegate?
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let skapeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: "Avenir-Black", size: 36)
        label.textColor = UIColor.mainGreenTint
        //label.addImageWith(name: "Homepage_logo", behindText: true)
//        label.textColor = UIColor.black
        return label
    }()
    
    private let AddressIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
//    private let linkingView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .mainOrangeTint
//        return view
//    }()
    
    private let propertyLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    lazy var propertyLocationTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Property Address"
        tf.textColor = .black
        
        let myColor : UIColor = UIColor.black
        tf.layer.borderColor = myColor.cgColor
        tf.backgroundColor = UIColor.white
        tf.layer.cornerRadius = 8.0
        tf.layer.masksToBounds = true
        tf.layer.borderColor = UIColor( red: 153/255, green: 153/255, blue:0/255, alpha: 1.0 ).cgColor
        tf.layer.borderWidth = 2.0
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 20)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 80, width:10)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.delegate = self
        tf.clearButtonMode = .whileEditing
        
        return tf
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        addShadow()
        backgroundColor = UIColor.white
        
//        backgroundColor = UIColor.rgb(red: 215, green: 215, blue: 215)
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 24, height: 25)
        
        addSubview(skapeLabel)
        skapeLabel.centerY(inView: backButton)
        skapeLabel.centerX(inView: self)
        
        addSubview(propertyLocationTextField)
        propertyLocationTextField.anchor(top: backButton.bottomAnchor, left: leftAnchor, right: rightAnchor,
                                         paddingTop: 40, paddingLeft: 40, paddingRight: 40, height: 30)
        
        //top: backButton.bottomAnchor, left: leftAnchor, right: view.rightAnchor, paddingTop: 40, paddingLeft: 16, paddingRight: 16
        
        addSubview(propertyLocationIndicatorView)
        propertyLocationIndicatorView.centerY(inView: propertyLocationTextField, leftAnchor: leftAnchor, paddingLeft: 20)
        propertyLocationIndicatorView.setDimensions(height: 6, width: 6)
        propertyLocationIndicatorView.layer.cornerRadius = 10 / 2
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func handleBackTapped() {
        delegate?.dismissLocationInputView()
    }
}

extension LocationInputView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else { return false }
        delegate?.executeSearch(query: query)
        return true
    }
}
