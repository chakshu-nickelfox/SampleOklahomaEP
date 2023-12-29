//
//  IAPManager.swift
//  Oklahoma
//
//  Created by Chakshu Dawara on 26/12/23.
//

import Foundation
import StoreKit

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    
    typealias BuyProductCompletion = (Result<PurchaseResponse, Error>) -> Void
    var onBuyProductHandler: BuyProductCompletion = {_ in }
    
    var totalRestoredPurchases = 0
    var restoreRequestModule = ""
    var restoredIDs = [String]()
    
    private override init() {
        super.init()
    }
    
    enum IAPManagerError: Error {
        case noProductIDsFound  // It indicates that the product identifiers could not be found.
        case noProductsFound // No IAP products were returned by the App Store because none was found.
        case paymentWasCancelled // The user cancelled an initialized purchase process.
        case productRequestFailed // The app cannot request App Store about available IAP products for some reason.
        case unknownError
    }
    
    fileprivate func getProductIDs() -> [String]? {
        // Product IDs
        let productIdentifiers = [Constant.ProductIdentifier.audiobookProductIdentifier,
                                  Constant.ProductIdentifier.examPrepProductIdentifier]
        return productIdentifiers
    }
    
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler
        
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }
        
        // init a products request for the app store
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func getPriceFormatted(for product: SKProduct) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price)
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }
    
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func buy(product: SKProduct, withHandler handler: @escaping BuyProductCompletion) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    func restorePurchases(module: SubModule, withHandler handler: @escaping BuyProductCompletion) {
        
        totalRestoredPurchases = 0
        switch module {
        case .examPrep:
            onBuyProductHandler = handler
            SKPaymentQueue.default().restoreCompletedTransactions()
            restoreRequestModule = Constant.ProductIdentifier.examPrepProductIdentifier
        case .audiobook:
            onBuyProductHandler = handler
            SKPaymentQueue.default().restoreCompletedTransactions()
            restoreRequestModule = Constant.ProductIdentifier.audiobookProductIdentifier
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if !products.isEmpty {
            onReceiveProductsHandler?(.success(products))
        } else {
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
}

extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound:
            return Constant.IAP.noProductIdentifiersFound
        case .noProductsFound:
            return Constant.IAP.noIAPFound
        case .productRequestFailed:
            return Constant.IAP.unableToFetchProduct
        case .paymentWasCancelled:
            return Constant.IAP.iapProcessCancelled
        case .unknownError:
            return Constant.IAP.unknownError
        }
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // Check state of a transcation changes
        transactions.forEach { transaction in
            
            switch transaction.transactionState {
            case .purchased:
                onBuyProductHandler(.success(PurchaseResponse(restoredModules: nil, success: true)))
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                restoredIDs.append(transaction.payment.productIdentifier)
                totalRestoredPurchases = 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler(.failure(error))
                    } else {
                        onBuyProductHandler(.failure(IAPManagerError.paymentWasCancelled))
                    }
                } else if let error = transaction.error {
                    onBuyProductHandler(.failure(error))
                } else {
                    onBuyProductHandler(.failure(IAPManagerError.unknownError))
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            onBuyProductHandler(.success(PurchaseResponse(restoredModules: restoredIDs, success: true)))
        } else {
            onBuyProductHandler(.success(PurchaseResponse(restoredModules: nil, success: false)))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                onBuyProductHandler(.failure(error))
            } else {
                onBuyProductHandler(.failure(IAPManagerError.paymentWasCancelled))
            }
        } else {
            onBuyProductHandler(.failure(error))
        }
    }
    
}

class PurchaseResponse {
    var purchasedModules: [String]?
    var success: Bool
    
    init(restoredModules: [String]?, success: Bool) {
        self.purchasedModules = restoredModules
        self.success = success
    }
}
