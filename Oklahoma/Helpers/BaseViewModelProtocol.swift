//
//  BaseViewModelProtocol.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 25/12/23.
//

import Foundation
import AnyErrorKit
import FLUtilities

public enum AlertType {
    case deleted
    case downloaded
    case bookmarked
    
    var backgroundColor: UIColor {
        return self == .deleted ? Colors.primaryRed : Colors.greenColor
    }
}

protocol BaseViewModelProtocol: AnyObject {
    func showErrorAlert(message: String?)
    func showAlert(message: String)
    func showAlert(title: String, message: String)
    func handleError(_ error: AnyError)
    func showAlert(title: String?, message: String?, actionInterfaceList: [ActionInterface], handler: @escaping AlertHandler)
    func showNoInternetAlert(_ message: String)
    func showFloatingMessage(_ message: String, type: AlertType)
    
}

extension UIViewController: BaseViewModelProtocol {
    func showFloatingMessage(_ message: String, type: AlertType) {
        self.presentFloatingAlert(message, type: type)
    }
    
    func handleError(_ error: AnyError) {
        print()
    }
    
    
    func showAlert(message: String) {
        let okActionInterface = ActionInterface(title: Constant.ok)
        
        self.showAlert(
            title: "",
            message: message,
            actionInterfaceList: [okActionInterface]) { _ in
            }
    }
    
    func showAlert(title: String, message: String) {
        self.showAlert(title: title, message: message) {}
    }
    
    func showAlert(title: String? = nil, message: String?, actionTitle: String = "Ok", actionBlock: @escaping (() -> Void)) {
        let list = [ActionInterface(title: actionTitle)]
        self.showAlert(
            title: title,
            message: message,
            actionInterfaceList: list) { actionInterface in
                if actionInterface.title == actionTitle {
                    actionBlock()
                }
            }
    }
    
    func showNoInternetAlert(_ message: String) {
        let okActionInterface = ActionInterface(title: Constant.ok)
        let title = Constant.noInternet
        
        self.showAlert(
            title: title,
            message: message,
            actionInterfaceList: [okActionInterface]) { _ in
            }
    }
    
    func showErrorAlert(error: NSError) {
        self.showErrorAlert(message: error.localizedDescription)
    }
    
    func showErrorAlert(message: String?) {
        let okActionInterface = ActionInterface(title: Constant.ok)
        let title = NSLocalizedString("Error", comment: "")
        
        self.showAlert(
            title: title,
            message: message,
            actionInterfaceList: [okActionInterface]) { _ in
                
            }
    }
    
    func showAlert(title: String?, message: String?, actionInterfaceList: [ActionInterface], handler: @escaping AlertHandler) {
        self.showAlertController(
            title: title,
            message: message,
            preferredStyle: .alert,
            actionInterfaceList: actionInterfaceList,
            handler: handler
        )
    }
    
    func showActionSheet(title: String?, message: String?, actionInterfaceList: [ActionInterface], handler: @escaping AlertHandler) {
        self.showAlertController(
            title: title,
            message: message,
            preferredStyle: .actionSheet,
            actionInterfaceList: actionInterfaceList,
            handler: handler
        )
    }
    
    func showAlertController(title: String?, message: String?, preferredStyle: UIAlertController.Style, actionInterfaceList: [ActionInterface], handler: @escaping AlertHandler) {
        let alertController = UIAlertController.alertController(
            title: title,
            message: message,
            preferredStyle: preferredStyle,
            actionInterfaceList: actionInterfaceList,
            handler: handler
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func dismissOnOk(title: String? = nil, message: String?, actionTitle: String = "Ok", actionBlock: @escaping (() -> Void)) {
        let list = [ActionInterface(title: actionTitle)]
        self.showAlert(
            title: title,
            message: message,
            actionInterfaceList: list) { actionInterface in
                if actionInterface.title == actionTitle {
                    actionBlock()
                }
            }
    }
}

extension UIViewController {
    func presentFloatingAlert(_ message: String, type: AlertType) {
        let alertHeight: CGFloat = UIScreen.main.bounds.height > 850 ? 100 : 80
        let alert = FloatAlertView(frame: CGRect(x: 0, y: -alertHeight, width: self.view.bounds.width, height: alertHeight))
        alert.messageLabel.text = message
        alert.messageLabel.textColor = type == .deleted ? .white : .black
        alert.messageLabel.superview?.backgroundColor = type.backgroundColor
        alert.accessibilityIdentifier = Constant.alert
        view.addSubview(alert)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
            alert.frame.origin.y = 0
        } completion: { _ in
            alert.removeAlert()
        }
        
    }
}

class FloatAlertView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }
    
    func configure() {
        Bundle.main.loadNibNamed(Constant.floatAlertView,
                                 owner: self,
                                 options: nil)
        addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth,
            .flexibleHeight]
    }
    
    func removeAlert() {
        UIView.animate(withDuration: 0.5,
                       delay: 1.0,
                       options: .curveEaseInOut) {
            self.frame.origin.y -= self.bounds.height
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
}
