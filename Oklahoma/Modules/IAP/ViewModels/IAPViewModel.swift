//
//  IAPViewModel.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import StoreKit

protocol IAPViewModelDelegate: AnyObject {
    func toggleOverlay(shouldShow: Bool)
    func willStartLongProcess()
    func didFinishLongProcess()
    func showIAPRelatedError(_ error: Error)
    func shouldUpdateUI()
    func didFinishRestoringPurchasesWithZeroProducts()
    func didFinishRestoringPurchasedProducts()
    func updateProductPriceOnButton()
    func updateButtonViewWithPurchaseSuccess(module: SubModule?)
}

class IAPViewModel {
    var delegate: IAPViewModelDelegate?
    private let model = IAPProductModel()
    
    init() {}
    
    fileprivate func updateDataWithPurchasedProduct(_ product: SKProduct) {
        // haptic after the purchase is complete
//        HapticFeedback.success()
        switch product.productIdentifier {
        case Constant.ProductIdentifier.examPrepProductIdentifier:
            UserDefaults.standard.set(true, forKey: Constant.ExamPrep.isExamPrepContentUnlocked)
            self.delegate?.updateButtonViewWithPurchaseSuccess(module: .examPrep)
        case Constant.ProductIdentifier.audiobookProductIdentifier:
            UserDefaults.standard.set(true, forKey: Constant.AudioBook.isAudioBookContentUnlocked)
            self.delegate?.updateButtonViewWithPurchaseSuccess(module: .audiobook)
        default:
            break
        }
    }
    
    fileprivate func updateDataWithRestoredProduct(module: SubModule) {
//        HapticFeedback.success()
        self.delegate?.updateButtonViewWithPurchaseSuccess(module: module)
    }
    
    func viewDidSetup() {
        delegate?.willStartLongProcess()
        
        IAPManager.shared.getProducts { (result) in
            
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()
                switch result {
                case .success(let products):
                    self.model.products = products
                    if !products.isEmpty {
                        self.delegate?.updateProductPriceOnButton()
                    }
                case .failure(let error): self.delegate?.showIAPRelatedError(error)
                }
            }
        }
    }
    
    func getProductForItem(productIdentifier: String) -> SKProduct? {
        // Check if there is a product fetched from App Store containing
        // the keyword matching to the selected item's index
        guard let product = model.getProduct(containing: productIdentifier) else { return nil }
        return product
    }
    
    func purchase(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            delegate?.willStartLongProcess()
            
            IAPManager.shared.buy(product: product) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.delegate?.didFinishLongProcess()
                    switch result {
                    case .success:
                        self.updateDataWithPurchasedProduct(product)
                    case .failure(let error):
                        self.delegate?.showIAPRelatedError(error)
                    }
                }
            }
        }
        
        return true
    }
    
    func restorePurchases(module: SubModule) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            delegate?.willStartLongProcess()
            IAPManager.shared.restorePurchases(module: module) { [weak self] result in
                guard let self = self else { return }
                self.delegate?.didFinishLongProcess()
                switch result {
                case .success(let response):
                    if response.success {
                        for id in response.purchasedModules ?? [] {
                            switch id {
                            case Constant.ProductIdentifier.examPrepProductIdentifier:
                                self.updateDataWithRestoredProduct(module: .examPrep)
                            case Constant.ProductIdentifier.audiobookProductIdentifier:
                                self.updateDataWithRestoredProduct(module: .audiobook)
                            default:
                                ()
                            }
                        }
                        self.delegate?.didFinishRestoringPurchasedProducts()
                    } else {
                        self.delegate?.didFinishRestoringPurchasesWithZeroProducts()
                    }
                case .failure(let error):
                    self.delegate?.showIAPRelatedError(error)
                }
            }
        }
        return true
    }
}
