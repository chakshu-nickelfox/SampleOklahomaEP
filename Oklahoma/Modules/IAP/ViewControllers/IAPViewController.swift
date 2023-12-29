//
//  IAPViewController.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import UIKit
import StoreKit

protocol IAPViewControllerDelegate: AnyObject {
    func updatePurchase(view: IAPViewController, success: Bool, module: SubModule)
    func updateRestore(view: IAPViewController, success: Bool)
}

class IAPViewController: UIViewController {
    
    @IBOutlet weak var overLayView: UIView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restorePurchaseButtonOutLet: UIButton!
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var appLogoImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bgGradientView: UIView!
    
    static var newInstance: IAPViewController? {
        let sb = UIStoryboard.init(name: Storyboard.inAppPurchase.name,
                                   bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: self.className()) as? IAPViewController
        return vc
    }
    
    weak var delegate: IAPViewControllerDelegate?
    var module: SubModule = .examPrep
    var productIdentifier = ""
    
    var viewModel = IAPViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        AppDelegate.shared?.setupNavigationBarBackground()
    }
    
    private func initialSetup() {
        self.viewModel.delegate = self
        self.overLayView.isHidden = true
//        AppDelegate.shared?.setupNavigationBarBackground(with: .clear)
        self.navigationController?.navigationBar.isHidden = true
        switch module {
        case .audiobook:
            self.productIdentifier = Constant.ProductIdentifier.audiobookProductIdentifier
        case .examPrep:
            self.productIdentifier = Constant.ProductIdentifier.examPrepProductIdentifier
        }
    }
    
    private func setupUI() {
        self.appLogoImageView.image = Image.IAP.appLogoIPhone.image
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.appLogoImageViewWidthConstraint.constant = 285.0
        } else {
            self.appLogoImageViewWidthConstraint.constant = 170.0
        }
    }
    
    private func setupGradient() {
        self.bgGradientView.layer.sublayers?.removeAll()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        self.bgGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func showSingleAlert(withMessage message: String) {
//        HapticFeedback.error()
        let alertController = UIAlertController(title: Constant.IAP.error, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constant.ok, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updatePriceOnButton(for product: SKProduct) {
        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
        purchaseButton.setTitle("\(Constant.IAP.purchase) (\(price))", for: .normal)
    }
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        guard let product = viewModel.getProductForItem(productIdentifier: productIdentifier)
        else {
            showSingleAlert(withMessage: Constant.IAP.buyingItemNotPossible)
            return
        }
        if self.viewModel.purchase(product: product) {
        }
    }
    
    @IBAction func restorePurchaseButtonAction(_ sender: Any) {
        if self.viewModel.restorePurchases(module: module) {
        }
    }
    
    @IBAction func dismissButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: IAPViewModel Delegate Methods
extension IAPViewController: IAPViewModelDelegate {
    
    func toggleOverlay(shouldShow: Bool) {
        overLayView.isHidden = !shouldShow
    }
    
    func willStartLongProcess() {
        overLayView.isHidden = false
    }
    
    func didFinishLongProcess() {
        overLayView.isHidden = true
    }
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        showSingleAlert(withMessage: message)
    }
    
    func shouldUpdateUI() {
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: Constant.IAP.noPurchasedRestore)
    }
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: Constant.IAP.previousPurchasesRestored)
    }
    
    func updateProductPriceOnButton() {
        guard let product = viewModel.getProductForItem(productIdentifier: productIdentifier)
        else {
            showSingleAlert(withMessage: Constant.IAP.buyingItemNotPossible)
            return
        }
        updatePriceOnButton(for: product)
    }
    
    func updateButtonViewWithPurchaseSuccess(module: SubModule?) {
        // Update UI with purchase succes callback.
        purchaseButton.setTitle(Constant.IAP.purchaseComplete, for: .normal)
        purchaseButton.backgroundColor = UIColor.green
        purchaseButton.isEnabled = false
        restorePurchaseButtonOutLet.isEnabled = false
        
        switch module {
        case .examPrep:
            DataModel.shared.isExamPrepPurchased = true
            self.delegate?.updatePurchase(view: self, success: true, module: .examPrep)
        case .audiobook:
            DataModel.shared.isAudioBookPurchased = true
            self.delegate?.updatePurchase(view: self, success: true, module: .audiobook)
        default:
            ()
        }
        dismiss(self)
    }
}
