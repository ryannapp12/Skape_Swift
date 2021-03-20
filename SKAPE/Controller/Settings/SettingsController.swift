//
//  SettingsController.swift
//  SKAPE
//
//  Created by Ryan Napolitano on 12/5/20.
//

import UIKit

private let reuseIdentifier = "LocationCell"

protocol SettingsControllerDelegate: class {
    func updateUser(_ controller: SettingsController)
}

enum LocationType: Int, CaseIterable, CustomStringConvertible {
    case propertyOne
    case propertyTwo

    var description: String {
        switch self {
        case .propertyOne: return "Property One"
        case .propertyTwo: return "Property Two"
        }
    }

    var subtitle: String {
        switch self {
        case .propertyOne: return "Add Property"
        case .propertyTwo: return "Add Property"
        }
    }
}

class SettingsController: UITableViewController {

    // MARK: - Properties

    var user: User
    private let locationManager = LocationHandler.shared.locationManager
    weak var delegate: SettingsControllerDelegate?
    var userInfoUpdated = false

    private lazy var infoHeader: UserInfoHeader = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        let view = UserInfoHeader(user: user, frame: frame)
        return view
    }()

    // MARK: - Lifecycle

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
        overrideUserInterfaceStyle = .light
    }

    // MARK: - Selectors

    @objc func handleDismissal() {
        if userInfoUpdated {
            delegate?.updateUser(self)
        }

        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Helper Functions

    func locationText(forType type: LocationType) -> String {
        switch type {
        case .propertyOne:
            return user.propertyOneLocation ?? type.subtitle
        case .propertyTwo:
            return user.propertyTwoLocation ?? type.subtitle
        }
    }

    func configureTableView() {
        tableView.rowHeight = 60
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = .white
        tableView.tableHeaderView = infoHeader
        tableView.tableFooterView = UIView()
    }

    func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Settings"

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismissal))
    }
}

// MARK: - UITableViewDelegate/DataSource

extension SettingsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationType.allCases.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.701908648, green: 0.658854425, blue: 7.196359365e-05, alpha: 1)

        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 16)
        title.textColor = .black
        title.text = "Properties"
        view.addSubview(title)
        title.centerY(inView: view, leftAnchor: view.leftAnchor, paddingLeft: 16)

        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell

        guard let type = LocationType(rawValue: indexPath.row) else { return cell }
        cell.titleLabel.text = type.description
        cell.addressLabel.text = locationText(forType: type)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = LocationType(rawValue: indexPath.row) else { return }
        guard let location = locationManager?.location else { return }
        let controller = AddLocationController(type: type, location: location)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true, completion: nil)
    }
}

// MARK: - AddLocationControllerDelegate

extension SettingsController: AddLocationControllerDelegate {
    func updateLocation(locationString: String, type: LocationType) {
        HomeownerService.shared.saveLocation(locationString: locationString, type: type) { (err, ref) in
            self.dismiss(animated: true, completion: nil)
            self.userInfoUpdated = true

            switch type {
            case .propertyOne:
                self.user.propertyOneLocation = locationString
            case .propertyTwo:
                self.user.propertyTwoLocation = locationString
            }

            self.tableView.reloadData()
        }
    }
}
