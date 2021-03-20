//
//  MenuHeader.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/4/20.
//  This is a test of git

import UIKit

class MenuHeader: UIView {
    
    //MARK: - Properties
    
//    var user: User? {
//        didSet{
//            fullnameLabel.text = user?.fullname
//            emailLabel.text = user?.email
//        }
//    }
    
    private let user: User
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "rsz_skape_website_logo.png")
        return iv
    }()
    
    private lazy var fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.text = user.email
        return label
    }()
    
    let jobModeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var jobModeSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        s.tintColor = .white
        s.onTintColor = #colorLiteral(red: 0.701908648, green: 0.658854425, blue: 7.196359365e-05, alpha: 1)
        s.addTarget(self, action: #selector(handleJobModeChanged), for: .valueChanged)
        return s
    }()
    
    //MARK: - Lifecycle
    
    init(user: User, frame: CGRect) {
        self.user = user
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 12, width: 64, height: 64)
        profileImageView.layer.cornerRadius = 64 / 2
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel, emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        addSubview(stack)
        stack.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 12)
        
        configureSwitch(enabled: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func handleJobModeChanged() {
        
    }
    
    // MARK: - Helper Functions
    
    func configureSwitch(enabled: Bool) {
        if user.accountType == .landscaper {
            addSubview(jobModeLabel)
            jobModeLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 16)
            
            addSubview(jobModeSwitch)
            jobModeSwitch.anchor(top: jobModeLabel.bottomAnchor, left: leftAnchor, paddingTop: 4, paddingLeft: 16)
            
            jobModeSwitch.isOn = enabled
            jobModeLabel.text = enabled ? "JOB MODE ENABLED" : "JOB MODE DISABLED"
        }
    }
}

