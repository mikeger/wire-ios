//
// Wire
// Copyright (C) 2024 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import UIKit
import WireSyncEngine

private let zmLog = ZMSLog(tag: "UI")

enum ClientSection: Int {
    case info = 0
    case fingerprintAndVerify = 1
    case resetSession = 2
    case removeDevice = 3
}

typealias SettingsClientViewModel = ProfileClientViewModel

final class SettingsClientViewController: UIViewController,
                                          UITableViewDelegate,
                                          UITableViewDataSource,
                                          UserClientObserver,
                                          ClientColorVariantProtocol,
                                          SpinnerCapable {

    // MARK: SpinnerCapable
    var dismissSpinner: SpinnerCompletion?

    private static let deleteCellReuseIdentifier: String = "DeleteCellReuseIdentifier"
    private static let resetCellReuseIdentifier: String = "ResetCellReuseIdentifier"
    private static let verifiedCellReuseIdentifier: String = "VerifiedCellReuseIdentifier"

    let userSession: UserSession
    let viewModel: ProfileClientViewModel
    var userClient: UserClient {
        viewModel.userClient
    }

    var userClientToken: NSObjectProtocol!
    var credentials: ZMEmailCredentials?

    var tableView: UITableView!
    let topSeparator = OverflowSeparatorView()

    var fromConversation: Bool = false

    var removalObserver: ClientRemovalObserver?

    convenience init(userClient: UserClient,
                     userSession: UserSession,
                     fromConversation: Bool,
                     credentials: ZMEmailCredentials? = .none) {
        self.init(userClient: userClient, userSession: userSession, credentials: credentials)
        self.fromConversation = fromConversation
    }

    required init(userClient: UserClient,
                  userSession: UserSession,
                  credentials: ZMEmailCredentials? = .none) {
        self.userSession = userSession
        self.viewModel = SettingsClientViewModel(userClient: userClient,
                                                 getUserClientFingerprint: userSession.getUserClientFingerprint)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = []
        self.userClientToken = UserClientChangeInfo.add(observer: self, for: userClient)

        self.viewModel.fingerprintDataClosure = { [weak self] _ in
            self?.tableView.reloadData()
        }

        setupNavigationTitle()
        self.credentials = credentials
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.topSeparator)
        self.createTableView()
        self.createConstraints()

        if fromConversation {
            setupFromConversationStyle()
        }
        setColor()

        self.viewModel.loadData()
    }

    func setupFromConversationStyle() {
        view.backgroundColor = SemanticColors.View.backgroundDefault
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: SemanticColors.Label.textDefault]
    }

    private func setupNavigationTitle() {
        guard let deviceClass = userClient.deviceClass?.localizedDescription else { return }
        navigationItem.setupNavigationBarTitle(title: deviceClass.capitalized)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // presented modally from conversation
        if let navController = self.navigationController,
            navController.viewControllers.count > 0 &&
            navController.viewControllers[0] == self,
            self.navigationItem.rightBarButtonItem == nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsClientViewController.onDonePressed(_:)))
            if fromConversation {
                let barColor = SemanticColors.View.backgroundDefault
                navController.navigationBar.barTintColor = barColor
            }
        }
    }

    private func createTableView() {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.backgroundColor = SemanticColors.View.backgroundDefault
        tableView.separatorStyle = .none
        tableView.register(ClientTableViewCell.self, forCellReuseIdentifier: ClientTableViewCell.zm_reuseIdentifier)
        tableView.register(FingerprintTableViewCell.self, forCellReuseIdentifier: FingerprintTableViewCell.zm_reuseIdentifier)
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: type(of: self).deleteCellReuseIdentifier)
        tableView.register(SettingsTableCell.self, forCellReuseIdentifier: type(of: self).resetCellReuseIdentifier)
        tableView.register(SettingsToggleCell.self, forCellReuseIdentifier: type(of: self).verifiedCellReuseIdentifier)
        self.tableView = tableView
        self.view.addSubview(tableView)
    }

    private func createConstraints() {
        [tableView, topSeparator].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
          tableView.topAnchor.constraint(equalTo: view.topAnchor),
          tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
          tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

          topSeparator.leftAnchor.constraint(equalTo: tableView.leftAnchor),
          topSeparator.rightAnchor.constraint(equalTo: tableView.rightAnchor),
          topSeparator.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
    }

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibNameOrNil:nibBundleOrNil:) has not been implemented")
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func onVerifiedChanged(_ sender: UISwitch!) {
        let selfClient = userSession.selfUserClient

        userSession.enqueue({
            if sender.isOn {
                selfClient?.trustClient(self.userClient)
            } else {
                selfClient?.ignoreClient(self.userClient)
            }
        }, completionHandler: {
            sender.isOn = self.userClient.verified
        })
    }

    @objc func onDonePressed(_ sender: AnyObject!) {
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: .none)
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {

        if self.userClient == userSession.selfUserClient {
            return 2
        } else {
            return userClient.type == .legalHold ? 3 : 4
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let clientSection = ClientSection(rawValue: section) else { return 0 }
        switch clientSection {

        case .info:
            return 1
        case .fingerprintAndVerify:
            if self.userClient == userSession.selfUserClient {
                return 1
            } else {
                return 2
            }
        case .resetSession:
            return 1
        case .removeDevice:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let clientSection = ClientSection(rawValue: (indexPath as NSIndexPath).section) else { return UITableViewCell() }

        switch clientSection {

        case .info:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ClientTableViewCell.zm_reuseIdentifier, for: indexPath) as? ClientTableViewCell {
                cell.selectionStyle = .default
                cell.wr_editable = false
                cell.accessibilityTraits = .none
                cell.accessibilityHint = ""
                cell.viewModel = .init(userClient: userClient, shouldSetType: false)
                return cell
            }

        case .fingerprintAndVerify:
            if (indexPath as NSIndexPath).row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: FingerprintTableViewCell.zm_reuseIdentifier, for: indexPath) as? FingerprintTableViewCell {
                    cell.selectionStyle = .none
                    cell.separatorInset = .zero
                    cell.fingerprint = self.viewModel.fingerprintData
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).verifiedCellReuseIdentifier, for: indexPath) as? SettingsToggleCell {
                    cell.titleText = L10n.Localizable.Device.verified
                    cell.cellNameLabel.accessibilityIdentifier = "device verified label"
                    cell.switchView.addTarget(self, action: #selector(SettingsClientViewController.onVerifiedChanged(_:)), for: .touchUpInside)
                    cell.switchView.accessibilityIdentifier = "device verified"
                    cell.accessibilityIdentifier = "device verified"
                    cell.switchView.isOn = self.userClient.verified
                    return cell
                }
            }

        case .resetSession:
            if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).resetCellReuseIdentifier, for: indexPath) as? SettingsTableCell {
                cell.titleText = L10n.Localizable.Profile.Devices.Detail.ResetSession.title
                cell.accessibilityIdentifier = "reset session"
                return cell
            }

        case .removeDevice:
            if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: self).deleteCellReuseIdentifier, for: indexPath) as? SettingsTableCell {
                cell.titleText = L10n.Localizable.Self.Settings.AccountDetails.RemoveDevice.title
                cell.accessibilityIdentifier = "remove device"
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let clientSection = ClientSection(rawValue: (indexPath as NSIndexPath).section) else { return }

        switch clientSection {
        case .resetSession:
            self.userClient.resetSession()
            isLoadingViewVisible = true

        case .removeDevice:
            removalObserver = nil

            let completion: ((Error?) -> Void) = { error in
                if error == nil {
                    self.navigationController?.popViewController(animated: true)
                }
            }

            removalObserver = ClientRemovalObserver(userClientToDelete: userClient,
                                                    delegate: self,
                                                    credentials: credentials,
                                                    completion: completion)

            removalObserver?.startRemoval()

        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let clientSection = ClientSection(rawValue: section) else { return .none }
        switch clientSection {

        case .fingerprintAndVerify:
            return L10n.Localizable.Self.Settings.DeviceDetails.Fingerprint.subtitle
        case .resetSession:
            return L10n.Localizable.Self.Settings.DeviceDetails.ResetSession.subtitle
        case .removeDevice:
            return L10n.Localizable.Self.Settings.DeviceDetails.RemoveDevice.subtitle

        default:
            return .none
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = headerFooterViewTextColor
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = headerFooterViewTextColor
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.topSeparator.scrollViewDidScroll(scrollView: scrollView)
    }

    // MARK: - Copying user client info

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == ClientSection.info.rawValue && indexPath.row == 0 {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {

        if action == #selector(UIResponder.copy(_:)) {
            return true
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(UIResponder.copy(_:)) {
            UIPasteboard.general.string = self.userClient.information
        }
    }

    // MARK: - UserClientObserver

    func userClientDidChange(_ changeInfo: UserClientChangeInfo) {
        if let tableView = self.tableView {
            tableView.reloadData()
        }

        if changeInfo.sessionHasBeenReset {
            isLoadingViewVisible = false
            let alert = UIAlertController(title: "", message: L10n.Localizable.Self.Settings.DeviceDetails.ResetSession.success, preferredStyle: .alert)
            let okAction = UIAlertAction(title: L10n.Localizable.General.ok, style: .default, handler: { [unowned alert] _ in
                alert.dismiss(animated: true, completion: .none)
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: .none)
        }
    }
}

// MARK: - ClientRemovalObserverDelegate

extension SettingsClientViewController: ClientRemovalObserverDelegate {
    func setIsLoadingViewVisible(_ clientRemovalObserver: ClientRemovalObserver, isVisible: Bool) {
        isLoadingViewVisible = isVisible
    }

    func present(_ clientRemovalObserver: ClientRemovalObserver, viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true)
    }
}

extension UserClient {
    var information: String {
        var lines = [String]()
        if let model = model {
            lines.append("Device: \(model)")
        }
        if let remoteIdentifier = remoteIdentifier {
            lines.append("ID: \(remoteIdentifier)")
        }
        if let pushToken = PushTokenStorage.pushToken {
            lines.append("Push Token: \(pushToken.deviceTokenString)")
        }
        return lines.joined(separator: "\n")
    }
}
